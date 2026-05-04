import type {Request, Response} from "express";
import * as logger from "firebase-functions/logger";
import {isAppError} from "../../../shared/errors";
import {normalizeEmail} from "../../../shared/utils";
import {verifyPasswordResetCode} from "../services/passwordResetService";

export async function verifyResetCodeHandler(
  req: Request,
  res: Response,
): Promise<void> {
  const email = normalizeEmail(String(req.body.email ?? ""));
  const code = String(req.body.code ?? "").trim();

  if (!email || !code) {
    res.status(400).json({
      message: "email e code sao obrigatorios.",
    });
    return;
  }

  try {
    const response = await verifyPasswordResetCode(email, code);
    res.status(200).json(response);
  } catch (error) {
    if (isAppError(error)) {
      res.status(error.status).json({
        message: error.message,
      });
      return;
    }

    logger.error("Erro ao validar codigo de recuperacao.", error);
    res.status(500).json({
      message: "Nao foi possivel validar o codigo informado.",
    });
  }
}
