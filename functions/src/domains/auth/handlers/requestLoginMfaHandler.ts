import type {Request, Response} from "express";
import * as logger from "firebase-functions/logger";
import {isAppError} from "../../../shared/errors";
import {requestLoginMfaCode} from "../services/loginMfaService";

export async function requestLoginMfaHandler(
  _req: Request,
  res: Response,
): Promise<void> {
  const uid = String(res.locals.authenticatedUserId ?? "").trim();

  if (!uid) {
    res.status(401).json({
      message: "Usuario nao autenticado.",
    });
    return;
  }

  try {
    const response = await requestLoginMfaCode(uid);
    res.status(200).json(response);
  } catch (error) {
    if (isAppError(error)) {
      res.status(error.status).json({
        message: error.message,
      });
      return;
    }

    logger.error("Erro ao enviar codigo de autenticacao multifator.", error);
    res.status(500).json({
      message: "Nao foi possivel iniciar a autenticacao multifator.",
    });
  }
}
