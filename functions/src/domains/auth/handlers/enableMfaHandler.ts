//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import type {Request, Response} from "express";
import * as logger from "firebase-functions/logger";
import {isAppError} from "../../../shared/errors";
import {enableMfa} from "../services/mfaService";

export async function enableMfaHandler(
  _req: Request,
  res: Response,
): Promise<void> {
  const uid = String((res.locals as {authenticatedUserId?: unknown}).authenticatedUserId ?? "");

  if (!uid) {
    res.status(401).json({message: "Usuario nao autenticado."});
    return;
  }

  try {
    const response = await enableMfa(uid);
    res.status(200).json(response);
  } catch (error) {
    if (isAppError(error)) {
      res.status(error.status).json({message: error.message});
      return;
    }

    logger.error("Erro ao ativar MFA.", error);
    res.status(500).json({message: "Erro ao ativar MFA."});
  }
}
