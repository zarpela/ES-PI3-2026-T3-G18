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

  // Valida o body
  const imageBase64 = req.body?.imageBase64;
  if (typeof imageBase64 !== "string" || imageBase64.trim().length === 0) {
    res.status(400).json({ ok: false, message: "imageBase64 é obrigatório." });
    return;
  }

  try {
    // Remove prefixo data:image/...;base64, se vier do front
    const base64Data = imageBase64.replace(/^data:image\/\w+;base64,/, "");
    const buffer = Buffer.from(base64Data, "base64");

    const bucket = storage.bucket();
    const filePath = `profile_pictures/${uid}.jpg`;
    const file = bucket.file(filePath);

    await file.save(buffer, {
      metadata: { contentType: "image/jpeg" },
    });

    // Torna o arquivo público e pega a URL
    await file.makePublic();
    const url = file.publicUrl();

    // Atualiza o photoURL no Firebase Auth
    await auth.updateUser(uid, { photoURL: url });

    logger.info("Foto de perfil atualizada.", { uid });

    res.status(200).json({ ok: true, url });
  } catch (error) {
    logger.error("Erro ao fazer upload da foto de perfil.", error);
    res.status(500).json({ ok: false, message: "Erro ao salvar a foto." });
  }
}
