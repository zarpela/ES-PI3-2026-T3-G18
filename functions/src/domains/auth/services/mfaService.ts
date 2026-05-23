/*
feito por Abdallah
RA: 25018711
*/

import {createAppError} from "../../../shared/errors";
import {auth} from "../../../shared/firebase";
import type {StoredMfaCode} from "../../../shared/types";
import {
  createFutureIsoString,
  generateVerificationCode,
  isExpired,
} from "../../../shared/utils";
import {sendMfaLoginCodeEmail} from "../repositories/mailRepository";
import {
  clearMfaCode,
  readMfaCode,
  readUserMfaEnabled,
  setUserMfaEnabled,
  storeMfaCode,
} from "../repositories/mfaRepository";

const mfaCodeExpiresInMinutes = 10;

export async function getMfaStatus(
  uid: string,
): Promise<{enabled: boolean}> {
  const enabled = await readUserMfaEnabled(uid);
  return {enabled};
}

export async function enableMfa(uid: string): Promise<{message: string}> {
  await setUserMfaEnabled(uid, true);
  return {message: "MFA ativado com sucesso."};
}

export async function disableMfa(uid: string): Promise<{message: string}> {
  await setUserMfaEnabled(uid, false);
  await clearMfaCode(uid);
  return {message: "MFA desativado com sucesso."};
}

export async function requestMfaLoginCode(
  uid: string,
): Promise<{message: string}> {
  const enabled = await readUserMfaEnabled(uid);

  if (!enabled) {
    throw createAppError(400, "MFA nao esta habilitado para este usuario.");
  }

  // O uid vem do token Firebase do usuario (middleware).
  // Buscamos o e-mail direto no Firebase Auth para evitar confiar em
  // dados enviados pelo cliente.
  const userRecord = await auth.getUser(uid);
  const email = userRecord.email?.trim().toLowerCase();

  if (!email) {
    throw createAppError(400, "Usuario nao possui e-mail cadastrado.");
  }

  // Gera um codigo de 6 digitos e persiste no Firestore com expiracao.
  // O codigo fica associado ao uid (1 codigo valido por usuario por vez).
  const code = generateVerificationCode();
  const expiresAt = createFutureIsoString(mfaCodeExpiresInMinutes);

  const record: StoredMfaCode = {
    code,
    email,
    expiresAt,
    uid,
  };

  await storeMfaCode(record);

  const emailSent = await sendMfaLoginCodeEmail(email, code);

  if (!emailSent) {
    await clearMfaCode(uid);
    throw createAppError(
      503,
      "Nao foi possivel enviar o codigo de verificacao. Tente novamente em instantes.",
    );
  }

  return {message: "Codigo enviado para o e-mail cadastrado."};
}

export async function verifyMfaLoginCode(
  uid: string,
  code: string,
): Promise<{message: string}> {
  const enabled = await readUserMfaEnabled(uid);

  if (!enabled) {
    throw createAppError(400, "MFA nao esta habilitado para este usuario.");
  }

  const record = await readMfaCode(uid);

  if (!record) {
    throw createAppError(400, "Codigo de verificacao invalido.");
  }

  // Compara o codigo e valida expiracao.
  // Se expirar ou for consumido, o registro e removido para impedir reuse.
  if (record.code !== code) {
    throw createAppError(400, "Codigo de verificacao invalido.");
  }

  if (isExpired(record.expiresAt)) {
    await clearMfaCode(uid);
    throw createAppError(400, "Codigo expirado. Solicite um novo codigo.");
  }

  // Codigo consumido: remove do Firestore e libera o login.
  await clearMfaCode(uid);

  return {message: "Login verificado com sucesso."};
}
