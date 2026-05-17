// feito por Gabriel Scolfaro

import type { Request, Response } from "express";
import * as logger from "firebase-functions/logger";
import { auth, storage } from "../../../shared/firebase";

/**
 * POST /upload-profile-photo
 *
 * Headers:
 *   Authorization: Bearer <idToken>
 *
 * Body (JSON):
 *   { "imageBase64": "<base64 string sem prefixo data:image/...>" }
 *
 * Retorna a URL pública da foto salva no Firebase Storage.
 */
export async function uploadProfilePhotoHandler(
  req: Request,
  res: Response,
): Promise<void> {
  // Extrai o token do header Authorization
  const authHeader = req.headers.authorization ?? "";
  const idToken = authHeader.startsWith("Bearer ")
    ? authHeader.slice(7).trim()
    : null;

  if (!idToken) {
    res.status(401).json({ ok: false, message: "Token não informado." });
    return;
  }

  // Verifica o token e obtém o uid
  let uid: string;
  try {
    const decoded = await auth.verifyIdToken(idToken);
    uid = decoded.uid;
  } catch {
    res.status(401).json({ ok: false, message: "Token inválido ou expirado." });
    return;
  }

  const imageBase64 = req.body?.imageBase64;

  // 1. Validação do tamanho da string Base64
  if (typeof imageBase64 !== "string" || imageBase64.length > 3000000) {
    res.status(413).json({ ok: false, message: "Payload muito grande ou inválido." });
    return;
  }

  try {
    // Remove prefixo data:image/...;base64, se vier do front
    const base64Data = imageBase64.replace(/^data:image\/\w+;base64,/, "");
    const buffer = Buffer.from(base64Data, "base64");

    // 2. Validação real do tamanho do arquivo (2MB)
    if (buffer.length > 2 * 1024 * 1024) {
      res.status(413).json({ ok: false, message: "A imagem deve ter no máximo 2MB." });
      return;
    }

    // 3. Validação de Magic Bytes (JPEG: FF D8 no início e FF D9 no fim)
    const isJpeg = buffer[0] === 0xFF && buffer[1] === 0xD8 && 
                   buffer[buffer.length - 2] === 0xFF && buffer[buffer.length - 1] === 0xD9;
    
    if (!isJpeg) {
      res.status(400).json({ ok: false, message: "Formato de arquivo inválido. Apenas JPEG é permitido." });
      return;
    }

    const bucket = storage.bucket();
    const filePath = `profile_pictures/${uid}.jpg`;
    const file = bucket.file(filePath);

    // 4. Salvar como privado (removido makePublic e publicUrl)
    await file.save(buffer, {
      metadata: { 
        contentType: "image/jpeg",
        cacheControl: "public, max-age=3600"
      },
      public: false, 
    });

    logger.info("Upload de foto realizado com sucesso e segurança.", { uid });

    res.status(200).json({
      ok: true,
      message: "Foto atualizada com sucesso!",
    });
  } catch (error) {
    logger.error("Erro no processamento do upload.", error);
    res.status(500).json({ ok: false, message: "Erro interno ao salvar foto." });
  }
}
