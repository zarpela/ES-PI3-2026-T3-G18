//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import {db} from "../../../shared/firebase";
import {createAppError} from "../../../shared/errors";
import {
  createFutureIsoString,
  generateVerificationCode,
  isExpired,
} from "../../../shared/utils";
import {findUserByUid} from "../repositories/authRepository";
import {
  clearLoginMfaCode,
  readLoginMfaCode,
  storeLoginMfaCode,
} from "../repositories/loginMfaRepository";
import {sendLoginMfaEmail} from "../repositories/mailRepository";

const loginMfaExpiresInMinutes = 10;

async function isMfaEnabledForUser(uid: string): Promise<boolean> {
  const snapshot = await db.collection("users").doc(uid).get();
  return snapshot.data()?.mfaEnabled === true;
}

async function ensureMfaEnabledForUser(uid: string): Promise<void> {
  const mfaEnabled = await isMfaEnabledForUser(uid);

  if (!mfaEnabled) {
    await clearLoginMfaCode(uid);
    throw createAppError(
      400,
      "Autenticacao multifator nao esta ativa para este usuario.",
    );
  }
}

export async function requestLoginMfaCode(
  uid: string,
): Promise<{email: string; message: string}> {
  await ensureMfaEnabledForUser(uid);

  const user = await findUserByUid(uid);
  if (!user || !user.email) {
    await clearLoginMfaCode(uid);
    throw createAppError(404, "Usuario nao encontrado.");
  }

  const code = generateVerificationCode();
  const expiresAt = createFutureIsoString(loginMfaExpiresInMinutes);

  await storeLoginMfaCode({
    code,
    email: user.email,
    expiresAt,
    uid,
  });

  const emailSent = await sendLoginMfaEmail(user.email, code);
  if (!emailSent) {
    await clearLoginMfaCode(uid);
    throw createAppError(
      503,
      "Nao foi possivel enviar o codigo de autenticacao multifator. Tente novamente em instantes.",
    );
  }

  return {
    email: user.email,
    message: "Codigo de autenticacao multifator enviado com sucesso.",
  };
}

export async function verifyLoginMfaCode(
  uid: string,
  code: string,
): Promise<{message: string}> {
  await ensureMfaEnabledForUser(uid);

  const storedCode = await readLoginMfaCode(uid);
  if (!storedCode) {
    throw createAppError(400, "Solicite um novo codigo para continuar.");
  }

  if (isExpired(storedCode.expiresAt)) {
    await clearLoginMfaCode(uid);
    throw createAppError(400, "Codigo expirado. Solicite um novo codigo.");
  }

  if (storedCode.code !== code || storedCode.uid !== uid) {
    throw createAppError(400, "Codigo de verificacao invalido.");
  }

  await clearLoginMfaCode(uid);

  return {
    message: "Codigo validado com sucesso.",
  };
}
