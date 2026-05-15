import type {Request, Response} from "express";
import * as logger from "firebase-functions/logger";
import {isAppError} from "../../../shared/errors";
import {normalizeEmail} from "../../../shared/utils";
import {resetPassword} from "../services/passwordResetService";

export async function resetPasswordHandler(
  req: Request,
  res: Response,
): Promise<void> {
  const email = normalizeEmail(String(req.body.email ?? ""));
  const newPassword = String(req.body.novaSenha ?? "");
  const code = String(req.body.code ?? "").trim();

  if (!email || !newPassword || !code) {
    res.status(400).json({
      message: "email, novaSenha e code sao obrigatorios.",
    });
    return;
  }

  try {
    const response = await resetPassword(email, newPassword, code);
    res.status(200).json(response);
  } catch (error) {
    if (isAppError(error)) {
      res.status(error.status).json({
        message: error.message,
      });
      return;
    }

    logger.error("Erro ao redefinir senha.", error);
    res.status(500).json({
      message: "Nao foi possivel redefinir a senha.",
    });
  }
}
