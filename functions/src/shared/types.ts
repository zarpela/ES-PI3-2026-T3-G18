export type LocalMailConfig = {
  mailUser?: string;
  mailPass?: string;
};

export type PasswordResetEmailStatus = "sent" | "testing" | "unavailable";

export type StoredResetCode = {
  code: string;
  email: string;
  expiresAt: string;
  uid: string;
  updatedAt?: string;
};

export type CreateUserInput = {
  cpf?: string;
  email?: string;
  name?: string;
  nome?: string;
  senha?: string;
  telefone?: string;
};
