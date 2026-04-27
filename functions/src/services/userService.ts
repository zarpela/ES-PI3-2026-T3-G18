import {auth, db} from "../config/firebase";

type CreateUserInput = {
  cpf?: string;
  email?: string;
  name?: string;
  nome?: string;
  senha?: string;
  telefone?: string;
};

type ServiceError = Error & {
  status?: number;
};

function createServiceError(status: number, message: string): ServiceError {
  const error = new Error(message) as ServiceError;
  error.status = status;
  return error;
}

function normalizeEmail(value: string): string {
  return value.trim().toLowerCase();
}

export const createUser = async (data: CreateUserInput) => {
  const nome = String(data.nome ?? data.name ?? "").trim();
  const email = normalizeEmail(String(data.email ?? ""));
  const senha = String(data.senha ?? "");
  const cpf = String(data.cpf ?? "").trim();
  const telefone = String(data.telefone ?? "").trim();

  if (!nome || !telefone || !email || !senha || !cpf) {
    throw createServiceError(
      400,
      "name, telefone, email, senha e cpf sao obrigatorios.",
    );
  }

  if (senha.length < 8) {
    throw createServiceError(400, "A senha deve ter pelo menos 8 caracteres.");
  }

  const userRecord = await auth.createUser({
    email,
    password: senha,
    displayName: nome,
  });

  await db.collection("users").doc(userRecord.uid).set({
    nome,
    cpf,
    telefone,
    email,
    createdAt: new Date(),
  });

  return userRecord;
};
