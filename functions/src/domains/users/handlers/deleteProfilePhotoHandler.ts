// Desenvolvido por Gabriel Scolfaro de Azeredo - RA: 25006194

import type { Request, Response } from "express";
import * as logger from "firebase-functions/logger";
import { auth, storage } from "../../../shared/firebase";

/**
 * DELETE /delete-profile-photo
 *
 * Headers:
 * Authorization: Bearer <idToken>
 *
 * Remove a foto de perfil do usuário no Firebase Storage e limpa a referência no Auth.
 */
export async function deleteProfilePhotoHandler(
  req: Request,
  res: Response,
): Promise<void> {
  const authHeader = req.headers.authorization ?? "";
  const idToken = authHeader.startsWith("Bearer ")
    ? authHeader.slice(7).trim()
    : null;

  if (!idToken) {
    res.status(401).json({ ok: false, message: "Token não informado." });
    return;
  }

  let uid: string;
  try {
    const decoded = await auth.verifyIdToken(idToken);
    uid = decoded.uid;
  } catch {
    res.status(401).json({ ok: false, message: "Token inválido ou expirado." });
    return;
  }

  try {
    const bucket = storage.bucket();
    const filePath = `profile_pictures/${uid}.jpg`;
    const file = bucket.file(filePath);

    const [exists] = await file.exists();
    if (exists) {
      await file.delete();
    }

    // Limpa o photoURL no Firebase Auth
    await auth.updateUser(uid, { photoURL: null });

    logger.info("Foto de perfil removida.", { uid });

    res.status(200).json({ ok: true, message: "Foto removida com sucesso." });
  } catch (error) {
    logger.error("Erro ao remover a foto de perfil.", error);
    res.status(500).json({ ok: false, message: "Erro ao remover a foto." });
  }
}
