import type {UserRecord} from "firebase-admin/auth";
import {createAppError} from "../../../shared/errors";
import type {CreateUserInput} from "../../../shared/types";
import {normalizeEmail} from "../../../shared/utils";
import {createAuthUser, saveUserProfile} from "../repositories/userRepository";

export async function createUser(data: CreateUserInput): Promise<UserRecord> {
  const nome = String(data.nome ?? data.name ?? "").trim();
  const email = normalizeEmail(String(data.email ?? ""));
  const senha = String(data.senha ?? "");
  const cpf = String(data.cpf ?? "").trim();
  const telefone = String(data.telefone ?? "").trim();

  if (!nome || !telefone || !email || !senha || !cpf) {
    throw createAppError(
      400,
      "name, telefone, email, senha e cpf sao obrigatorios.",
    );
  }

  if (senha.length < 8) {
    throw createAppError(400, "A senha deve ter pelo menos 8 caracteres.");
  }

  const userRecord = await createAuthUser({
    email,
    password: senha,
    displayName: nome,
  });

  await saveUserProfile(userRecord.uid, {
    nome,
    cpf,
    telefone,
    email,
    createdAt: new Date(),
  });

  return userRecord;
}
