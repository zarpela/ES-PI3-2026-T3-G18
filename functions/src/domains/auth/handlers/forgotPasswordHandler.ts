import type {Request, Response} from "express";
import * as logger from "firebase-functions/logger";
import {isAppError} from "../../../shared/errors";
import {normalizeEmail} from "../../../shared/utils";
import {
  requestPasswordReset,
} from "../services/passwordResetService";

export async function forgotPasswordHandler(
  req: Request,
  res: Response,
): Promise<void> {
  const email = normalizeEmail(String(req.body.identifier ?? req.body.email ?? ""));

  if (!email) {
    res.status(400).json({
      message: "identifier e obrigatorio.",
    });
    return;
  }

  try {
    const response = await requestPasswordReset(email);
    res.status(200).json(response);
  } catch (error) {
    if (isAppError(error)) {
      res.status(error.status).json({
        message: error.message,
      });
      return;
    }

    logger.error("Erro ao enviar e-mail de recuperacao.", error);
    res.status(500).json({
      message: "Nao foi possivel enviar o codigo de recuperacao.",
    });
  }
}
