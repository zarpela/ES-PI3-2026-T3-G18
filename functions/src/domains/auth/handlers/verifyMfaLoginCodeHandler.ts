/*
feito por Abdallah
RA: 25018711
*/

import type {Request, Response} from "express";
import * as logger from "firebase-functions/logger";
import {isAppError} from "../../../shared/errors";
import {verifyMfaLoginCode} from "../services/mfaService";

export async function verifyMfaLoginCodeHandler(
  req: Request,
  res: Response,
): Promise<void> {
  const uid = String((res.locals as {authenticatedUserId?: unknown}).authenticatedUserId ?? "");

  if (!uid) {
    res.status(401).json({message: "Usuario nao autenticado."});
    return;
  }

  const code = String(req.body?.code ?? "").trim();

  if (!code) {
    res.status(400).json({message: "code e obrigatorio."});
    return;
  }

  try {
    const response = await verifyMfaLoginCode(uid, code);
    res.status(200).json(response);
  } catch (error) {
    if (isAppError(error)) {
      res.status(error.status).json({message: error.message});
      return;
    }

    logger.error("Erro ao verificar codigo de MFA.", error);
    res.status(500).json({message: "Erro ao verificar codigo de MFA."});
  }
}
