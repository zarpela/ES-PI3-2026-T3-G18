import type {Request, Response} from "express";
import * as logger from "firebase-functions/logger";
import {getErrorMessage, getErrorStatus} from "../../../shared/errors";
import {createUser} from "../services/createUserService";

export async function createAccountHandler(
  req: Request,
  res: Response,
): Promise<void> {
  try {
    const user = await createUser(req.body);

    res.status(201).json({
      ok: true,
      message: "Usuario cadastrado com sucesso.",
      userId: user.uid,
    });
  } catch (error) {
    logger.error("Erro ao criar conta.", error);

    const message = getErrorMessage(error, "Erro ao criar conta");

    res.status(getErrorStatus(error)).json({
      ok: false,
      error: message,
      message,
    });
  }
}
