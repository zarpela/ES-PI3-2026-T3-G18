import {createAppError} from "../../../shared/errors";
import type {StoredResetCode} from "../../../shared/types";
import {
  createFutureIsoString,
  generateVerificationCode,
  isExpired,
} from "../../../shared/utils";
import {
  findUserByEmail,
  updateUserPassword,
} from "../repositories/authRepository";
import {
  clearResetCode,
  readResetCode,
  storeResetCode,
} from "../repositories/passwordResetRepository";
import {sendPasswordResetEmail} from "../repositories/mailRepository";

const resetCodeExpiresInMinutes = 15;

export function buildForgotPasswordResponse(): {message: string} {
  return {
    message:
      "Se o e-mail estiver cadastrado, enviaremos as instrucoes de recuperacao.",
  };
}

async function invalidateResetCode(email: string): Promise<void> {
  await clearResetCode(email);
}

export async function requestPasswordReset(
  email: string,
): Promise<{message: string}> {
  const user = await findUserByEmail(email);

  if (!user) {
    await invalidateResetCode(email);
    return buildForgotPasswordResponse();
  }

  const code = generateVerificationCode();
  const expiresAt = createFutureIsoString(resetCodeExpiresInMinutes);

  await storeResetCode({
    code,
    email,
    expiresAt,
    uid: user.uid,
  });

  const emailSent = await sendPasswordResetEmail(email, code);

  if (!emailSent) {
    await invalidateResetCode(email);
    throw createAppError(
      503,
      "Nao foi possivel enviar o codigo de recuperacao. Tente novamente em instantes.",
    );
  }

  return buildForgotPasswordResponse();
}

export async function verifyPasswordResetCode(
  email: string,
  code: string,
): Promise<{message: string}> {
  const user = await findUserByEmail(email);
  const resetCode = await readResetCode(email);

  if (!user || !resetCode) {
    await invalidateResetCode(email);
    throw createAppError(400, "Codigo de verificacao invalido.");
  }

  await validateResetCode(email, user.uid, resetCode, code);

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

  if (!user || !resetCode) {
    await invalidateResetCode(email);
    throw createAppError(400, "Codigo de verificacao invalido.");
  }

  await validateResetCode(email, user.uid, resetCode, code);

  await updateUserPassword(user.uid, newPassword);
  await clearResetCode(email);

  return {
    message: "Senha redefinida com sucesso.",
  };
}

async function validateResetCode(
  email: string,
  userId: string,
  resetCode: StoredResetCode,
  code: string,
): Promise<void> {
  if (resetCode.code !== code || resetCode.uid !== userId) {
    await invalidateResetCode(email);
    throw createAppError(400, "Codigo de verificacao invalido.");
  }

  if (isExpired(resetCode.expiresAt)) {
    await invalidateResetCode(email);
    throw createAppError(400, "Codigo expirado. Solicite um novo codigo.");
  }
}
