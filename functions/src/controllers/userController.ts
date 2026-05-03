import {Request, Response} from "express";
import {createUser} from "../services/userService";

function getErrorStatus(error: unknown): number {
  const status = (error as {status?: unknown}).status;

  if (typeof status === "number") {
    return status;
  }

  const code = (error as {code?: unknown}).code;

  if (code === "auth/email-already-exists") {
    return 409;
  }

  return 400;
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error && error.message) {
    return error.message;
  }

  const code = (error as {code?: unknown}).code;

  if (code === "auth/email-already-exists") {
    return "Ja existe um usuario com esse email.";
  }

  if (code === "auth/invalid-email") {
    return "Informe um e-mail valido.";
  }

  if (code === "auth/invalid-password") {
    return "A senha deve ter pelo menos 8 caracteres.";
  }

  return "Erro ao criar conta";
}

export const createAccount = async (req: Request, res: Response) => {
  try {
    const user = await createUser(req.body);

    return res.status(201).json({
      ok: true,
      message: "Usuario cadastrado com sucesso.",
      userId: user.uid,
    });
  } catch (error) {
    console.error(error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};
