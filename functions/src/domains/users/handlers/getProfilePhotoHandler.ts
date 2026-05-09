// feito por Gabriel Scolfaro

import type { Request, Response } from "express";
import * as logger from "firebase-functions/logger";
import { auth, storage } from "../../../shared/firebase";

/**
 * GET /profile-photo
 *
 * Headers:
 *   Authorization: Bearer <idToken>
 *
 * Retorna os bytes da foto de perfil do usuário autenticado.
 * Resolve o problema de CORS ao buscar direto do Storage pelo browser.
 */
export async function getProfilePhotoHandler(
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
    const file = bucket.file(`profile_pictures/${uid}.jpg`);

    const [exists] = await file.exists();
    if (!exists) {
      res.status(404).json({ ok: false, message: "Foto não encontrada." });
      return;
    }

    const [bytes] = await file.download();

    res.set("Content-Type", "image/jpeg");
    res.set("Cache-Control", "private, max-age=300");
    res.status(200).send(bytes);
  } catch (error) {
    logger.error("Erro ao buscar foto de perfil.", error);
    res.status(500).json({ ok: false, message: "Erro ao buscar a foto." });
  }
}
