import {createAppError} from "../../../shared/errors";
import type {StoredResetCode} from "../../../shared/types";
import {
  createFutureIsoString,
  generateVerificationCode,
  isExpired,
  shouldReturnCodeForTesting,
} from "../../../shared/utils";
import {findUserByEmail, updateUserPassword} from "../repositories/authRepository";
import {
  clearResetCode,
  readResetCode,
  storeResetCode,
} from "../repositories/passwordResetRepository";
import {sendPasswordResetEmail} from "../repositories/mailRepository";

const resetCodeExpiresInMinutes = 15;

export async function requestPasswordReset(email: string): Promise<{
  message: string;
  email: string;
  code?: string;
}> {
  const user = await findUserByEmail(email);

  if (!user) {
    throw createAppError(404, "Usuario nao encontrado.");
  }

  const code = generateVerificationCode();
  const expiresAt = createFutureIsoString(resetCodeExpiresInMinutes);

  await storeResetCode({
    code,
    email,
    expiresAt,
    uid: user.uid,
  });

  const emailStatus = await sendPasswordResetEmail(email, code);

  if (emailStatus === "unavailable") {
    throw createAppError(
      503,
      "Nao foi possivel enviar o e-mail de recuperacao de senha.",
    );
  }

  return {
    message: emailStatus === "sent" ?
      "Codigo de verificacao enviado por e-mail." :
      "Codigo gerado para teste local.",
    email,
    ...(shouldReturnCodeForTesting() ? {code} : {}),
  };
}

export async function verifyPasswordResetCode(
  email: string,
  code: string,
): Promise<{message: string}> {
  const user = await findUserByEmail(email);
  const resetCode = await readResetCode(email);

  if (!user) {
    throw createAppError(404, "Usuario nao encontrado.");
  }

  validateResetCode(resetCode, code);

  return {
    message: "Codigo validado com sucesso.",
  };
}

export async function resetPassword(
  email: string,
  newPassword: string,
  code: string,
): Promise<{message: string}> {
  if (newPassword.length < 8) {
    throw createAppError(400, "A senha deve ter pelo menos 8 caracteres.");
  }

  const user = await findUserByEmail(email);
  const resetCode = await readResetCode(email);

  if (!user) {
    throw createAppError(404, "Usuario nao encontrado.");
  }

  validateResetCode(resetCode, code);

  await updateUserPassword(user.uid, newPassword);
  await clearResetCode(email);

  return {
    message: "Senha redefinida com sucesso.",
  };
}

function validateResetCode(
  resetCode: StoredResetCode | null,
  code: string,
): void {
  if (!resetCode || resetCode.code !== code) {
    throw createAppError(400, "Codigo de verificacao invalido.");
  }

  if (isExpired(resetCode.expiresAt)) {
    throw createAppError(400, "Codigo expirado. Solicite um novo codigo.");
  }
}
