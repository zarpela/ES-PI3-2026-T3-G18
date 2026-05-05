/*
Autor: [COLOQUE SEU NOME COMPLETO]
RA: [COLOQUE SEU RA]
*/

import {db} from "../shared/firebase";

type CreateWalletInput = {
  authenticatedUserId?: string;
  userId?: string;
};

type AddBalanceInput = {
  amount?: number | string;
  authenticatedUserId?: string;
  userId?: string;
};

type WithdrawBalanceInput = {
  amount?: number | string;
  authenticatedUserId?: string;
  userId?: string;
};

type WalletAccessInput = {
  authenticatedUserId?: string;
  userId?: string;
};

type WalletToken = {
  averagePrice: number;
  quantity: number;
  startupId: string;
  startupName: string;
};

type WalletDocument = {
  balance: number;
  createdAt: string;
  tokens: WalletToken[];
  updatedAt: string;
  userId: string;
};

type WalletTransactionType =
  | "CREATE_WALLET"
  | "ADD_BALANCE"
  | "WITHDRAW_BALANCE"
  | "BUY_TOKEN"
  | "SELL_TOKEN";

type WalletTransaction = {
  amount: number;
  createdAt: string;
  description: string;
  type: WalletTransactionType;
  userId: string;
};

type ServiceError = Error & {
  status?: number;
};

const walletsCollection = "wallets";
const walletTransactionsCollection = "walletTransactions";
const unauthorizedMessage = "Usuario nao autenticado.";
const forbiddenMessage = "Voce nao tem permissao para acessar esta carteira.";

function createServiceError(status: number, message: string): ServiceError {
  const error = new Error(message) as ServiceError;
  error.status = status;
  return error;
}

function normalizeUserId(value: string): string {
  return value.trim();
}

function resolveAuthorizedUserId(data: WalletAccessInput): string {
  const authenticatedUserId = normalizeUserId(
    String(data.authenticatedUserId ?? ""),
  );
  const requestedUserId = normalizeUserId(String(data.userId ?? ""));

  if (!authenticatedUserId) {
    throw createServiceError(401, unauthorizedMessage);
  }

  if (requestedUserId && requestedUserId !== authenticatedUserId) {
    throw createServiceError(403, forbiddenMessage);
  }

  return requestedUserId || authenticatedUserId;
}

function parseAmount(value: number | string | undefined): number {
  if (typeof value === "number") {
    return value;
  }

  if (typeof value === "string" && value.trim()) {
    return Number(value);
  }

  return Number.NaN;
}

function getWalletRef(userId: string) {
  return db.collection(walletsCollection).doc(userId);
}

function buildWalletDocument(userId: string, createdAt: string): WalletDocument {
  return {
    userId,
    balance: 0,
    tokens: [],
    createdAt,
    updatedAt: createdAt,
  };
}

function normalizeTokens(tokens: unknown): WalletToken[] {
  if (!Array.isArray(tokens)) {
    return [];
  }

  return tokens.map((token) => ({
    startupId: String((token as WalletToken).startupId ?? ""),
    startupName: String((token as WalletToken).startupName ?? ""),
    quantity: Number((token as WalletToken).quantity ?? 0),
    averagePrice: Number((token as WalletToken).averagePrice ?? 0),
  }));
}

function normalizeWalletData(userId: string, data: Partial<WalletDocument>): WalletDocument {
  return {
    userId,
    balance: Number(data.balance ?? 0),
    tokens: normalizeTokens(data.tokens),
    createdAt: String(data.createdAt ?? ""),
    updatedAt: String(data.updatedAt ?? ""),
  };
}

export const createWallet = async (data: CreateWalletInput) => {
  const userId = resolveAuthorizedUserId(data);

  const walletRef = getWalletRef(userId);

  return db.runTransaction(async (transaction) => {
    const walletSnapshot = await transaction.get(walletRef);

    if (walletSnapshot.exists) {
      throw createServiceError(409, "Ja existe uma carteira para esse usuario.");
    }

    const createdAt = new Date().toISOString();
    const wallet = buildWalletDocument(userId, createdAt);
    const walletTransactionRef = db.collection(walletTransactionsCollection).doc();

    // O userId como id do documento garante unicidade da carteira por usuario.
    transaction.set(walletRef, wallet);
    transaction.set(walletTransactionRef, {
      userId,
      type: "CREATE_WALLET",
      amount: 0,
      description: "Carteira criada com saldo inicial zerado.",
      createdAt,
    } satisfies WalletTransaction);

    return wallet;
  });
};

export const getWalletByUserId = async (data: WalletAccessInput) => {
  const userId = resolveAuthorizedUserId(data);

  const walletSnapshot = await getWalletRef(userId).get();

  if (!walletSnapshot.exists) {
    throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
  }

  return normalizeWalletData(
    userId,
    walletSnapshot.data() as Partial<WalletDocument>,
  );
};

export const addBalanceToWallet = async (data: AddBalanceInput) => {
  const userId = resolveAuthorizedUserId(data);
  const amount = parseAmount(data.amount);

  if (!Number.isFinite(amount)) {
    throw createServiceError(400, "amount deve ser um numero valido.");
  }

  if (amount <= 0) {
    throw createServiceError(400, "amount deve ser maior que 0.");
  }

  const walletRef = getWalletRef(userId);

  return db.runTransaction(async (transaction) => {
    const walletSnapshot = await transaction.get(walletRef);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    const wallet = normalizeWalletData(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const updatedAt = new Date().toISOString();
    const updatedWallet: WalletDocument = {
      ...wallet,
      balance: wallet.balance + amount,
      updatedAt,
    };
    const walletTransactionRef = db.collection(walletTransactionsCollection).doc();

    transaction.set(walletRef, updatedWallet);
    transaction.set(walletTransactionRef, {
      userId,
      type: "ADD_BALANCE",
      amount,
      description: `Saldo ficticio adicionado a carteira: R$ ${amount.toFixed(2)}.`,
      createdAt: updatedAt,
    } satisfies WalletTransaction);

    return updatedWallet;
  });
};

export const withdrawBalanceFromWallet = async (data: WithdrawBalanceInput) => {
  const userId = resolveAuthorizedUserId(data);
  const amount = parseAmount(data.amount);

  if (!Number.isFinite(amount)) {
    throw createServiceError(400, "amount deve ser um numero valido.");
  }

  if (amount <= 0) {
    throw createServiceError(400, "amount deve ser maior que 0.");
  }

  const walletRef = getWalletRef(userId);

  return db.runTransaction(async (transaction) => {
    const walletSnapshot = await transaction.get(walletRef);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    const wallet = normalizeWalletData(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );

    if (wallet.balance < amount) {
      throw createServiceError(400, "Saldo insuficiente para realizar o saque.");
    }

    const updatedAt = new Date().toISOString();
    const updatedWallet: WalletDocument = {
      ...wallet,
      balance: wallet.balance - amount,
      updatedAt,
    };
    const walletTransactionRef = db.collection(walletTransactionsCollection).doc();

    transaction.set(walletRef, updatedWallet);
    transaction.set(walletTransactionRef, {
      userId,
      type: "WITHDRAW_BALANCE",
      amount,
      description: `Saque realizado da carteira: R$ ${amount.toFixed(2)}.`,
      createdAt: updatedAt,
    } satisfies WalletTransaction);

    return updatedWallet;
  });
};

export const listWalletTokens = async (data: WalletAccessInput) => {
  const wallet = await getWalletByUserId(data);
  return wallet.tokens;
};
