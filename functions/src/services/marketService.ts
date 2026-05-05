/*
Autor: [SEU NOME]
RA: [SEU RA]
*/

import {db} from "../shared/firebase";

type MarketOperationInput = {
  authenticatedUserId?: string;
  price?: number | string;
  quantity?: number | string;
  startupId?: string;
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

type MarketTransactionType = "BUY" | "SELL";

type MarketTransaction = {
  createdAt: string;
  price: number;
  quantity: number;
  startupId: string;
  total: number;
  type: MarketTransactionType;
  userId: string;
};

type WalletHistoryTransaction = {
  [key: string]: unknown;
  createdAt: string;
  type: string;
  userId: string;
};

type WalletHistoryTransactionResponse = WalletHistoryTransaction & {
  id: string;
};

type ServiceError = Error & {
  status?: number;
};

const forbiddenMessage = "Voce nao tem permissao para acessar esta carteira.";
const startupsCollection = "startups";
const unauthorizedMessage = "Usuario nao autenticado.";
const walletTransactionsCollection = "walletTransactions";
const walletsCollection = "wallets";

function createServiceError(status: number, message: string): ServiceError {
  const error = new Error(message) as ServiceError;
  error.status = status;
  return error;
}

function normalizeString(value: string): string {
  return value.trim();
}

function normalizeUserId(value: string): string {
  return normalizeString(value);
}

function resolveAuthorizedUserId(data: MarketOperationInput): string {
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

function parseNumber(value: number | string | undefined): number {
  if (typeof value === "number") {
    return value;
  }

  if (typeof value === "string" && value.trim()) {
    return Number(value);
  }

  return Number.NaN;
}

function parsePositiveNumber(
  value: number | string | undefined,
  fieldName: string,
): number {
  const parsedValue = parseNumber(value);

  if (!Number.isFinite(parsedValue)) {
    throw createServiceError(400, `${fieldName} deve ser um numero valido.`);
  }

  if (parsedValue <= 0) {
    throw createServiceError(400, `${fieldName} deve ser maior que 0.`);
  }

  return parsedValue;
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

function normalizeWalletData(
  userId: string,
  data: Partial<WalletDocument>,
): WalletDocument {
  return {
    userId,
    balance: Number(data.balance ?? 0),
    tokens: normalizeTokens(data.tokens),
    createdAt: String(data.createdAt ?? ""),
    updatedAt: String(data.updatedAt ?? ""),
  };
}

function extractStartupName(startupId: string, data: Record<string, unknown>): string {
  const startupName = String(
    data.startupName ?? data.name ?? data.nome ?? data.title ?? startupId,
  ).trim();

  if (!startupName) {
    return startupId;
  }

  return startupName;
}

async function getStartupNameById(startupId: string): Promise<string> {
  const startupSnapshot = await db.collection(startupsCollection).doc(startupId).get();

  if (!startupSnapshot.exists) {
    throw createServiceError(404, "Startup nao encontrada.");
  }

  return extractStartupName(
    startupId,
    startupSnapshot.data() as Record<string, unknown>,
  );
}

function buildMarketTransaction(
  userId: string,
  type: MarketTransactionType,
  startupId: string,
  quantity: number,
  price: number,
  createdAt: string,
): MarketTransaction {
  return {
    userId,
    type,
    startupId,
    quantity,
    price,
    total: quantity * price,
    createdAt,
  };
}

function buyTokensInWallet(
  tokens: WalletToken[],
  startupId: string,
  startupName: string,
  quantity: number,
  price: number,
): WalletToken[] {
  const existingTokenIndex = tokens.findIndex(
    (token) => token.startupId === startupId,
  );

  if (existingTokenIndex < 0) {
    return [
      ...tokens,
      {
        startupId,
        startupName,
        quantity,
        averagePrice: price,
      },
    ];
  }

  const existingToken = tokens[existingTokenIndex];
  const updatedQuantity = existingToken.quantity + quantity;
  const updatedAveragePrice =
    ((existingToken.quantity * existingToken.averagePrice) + (quantity * price)) /
    updatedQuantity;

  return tokens.map((token, index) => {
    if (index !== existingTokenIndex) {
      return token;
    }

    return {
      ...token,
      startupName,
      quantity: updatedQuantity,
      averagePrice: updatedAveragePrice,
    };
  });
}

function sellTokensFromWallet(
  tokens: WalletToken[],
  startupId: string,
  quantity: number,
): WalletToken[] {
  const existingTokenIndex = tokens.findIndex(
    (token) => token.startupId === startupId,
  );

  if (existingTokenIndex < 0) {
    throw createServiceError(400, "Voce nao possui tokens dessa startup.");
  }

  const existingToken = tokens[existingTokenIndex];

  if (existingToken.quantity < quantity) {
    throw createServiceError(400, "Quantidade de tokens insuficiente para venda.");
  }

  const remainingQuantity = existingToken.quantity - quantity;

  if (remainingQuantity === 0) {
    return tokens.filter((token) => token.startupId !== startupId);
  }

  return tokens.map((token, index) => {
    if (index !== existingTokenIndex) {
      return token;
    }

    return {
      ...token,
      quantity: remainingQuantity,
    };
  });
}

export const buyTokens = async (data: MarketOperationInput) => {
  const userId = resolveAuthorizedUserId(data);
  const startupId = normalizeString(String(data.startupId ?? ""));
  const quantity = parsePositiveNumber(data.quantity, "quantity");
  const price = parsePositiveNumber(data.price, "price");

  if (!startupId) {
    throw createServiceError(400, "startupId e obrigatorio.");
  }

  const startupName = await getStartupNameById(startupId);
  const walletRef = db.collection(walletsCollection).doc(userId);

  return db.runTransaction(async (transaction) => {
    const walletSnapshot = await transaction.get(walletRef);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    const wallet = normalizeWalletData(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const marketTransactionRef = db.collection(walletTransactionsCollection).doc();
    const createdAt = new Date().toISOString();
    const marketTransaction = buildMarketTransaction(
      userId,
      "BUY",
      startupId,
      quantity,
      price,
      createdAt,
    );

    if (wallet.balance < marketTransaction.total) {
      throw createServiceError(400, "Saldo insuficiente para concluir a compra.");
    }

    const updatedWallet: WalletDocument = {
      ...wallet,
      balance: wallet.balance - marketTransaction.total,
      tokens: buyTokensInWallet(
        wallet.tokens,
        startupId,
        startupName,
        quantity,
        price,
      ),
      updatedAt: createdAt,
    };

    transaction.set(walletRef, updatedWallet);
    transaction.set(marketTransactionRef, marketTransaction);

    return {
      wallet: updatedWallet,
      transaction: marketTransaction,
    };
  });
};

export const sellTokens = async (data: MarketOperationInput) => {
  const userId = resolveAuthorizedUserId(data);
  const startupId = normalizeString(String(data.startupId ?? ""));
  const quantity = parsePositiveNumber(data.quantity, "quantity");
  const price = parsePositiveNumber(data.price, "price");

  if (!startupId) {
    throw createServiceError(400, "startupId e obrigatorio.");
  }

  const walletRef = db.collection(walletsCollection).doc(userId);

  return db.runTransaction(async (transaction) => {
    const walletSnapshot = await transaction.get(walletRef);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    const wallet = normalizeWalletData(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const createdAt = new Date().toISOString();
    const marketTransaction = buildMarketTransaction(
      userId,
      "SELL",
      startupId,
      quantity,
      price,
      createdAt,
    );
    const updatedWallet: WalletDocument = {
      ...wallet,
      balance: wallet.balance + marketTransaction.total,
      tokens: sellTokensFromWallet(wallet.tokens, startupId, quantity),
      updatedAt: createdAt,
    };
    const marketTransactionRef = db.collection(walletTransactionsCollection).doc();

    transaction.set(walletRef, updatedWallet);
    transaction.set(marketTransactionRef, marketTransaction);

    return {
      wallet: updatedWallet,
      transaction: marketTransaction,
    };
  });
};

export const getWalletTransactionHistory = async (
  data: MarketOperationInput,
): Promise<WalletHistoryTransactionResponse[]> => {
  const userId = resolveAuthorizedUserId(data);
  const transactionsSnapshot = await db
    .collection(walletTransactionsCollection)
    .where("userId", "==", userId)
    .orderBy("createdAt", "desc")
    .get();

  if (transactionsSnapshot.empty) {
    return [];
  }

  return transactionsSnapshot.docs.map((document) => ({
    id: document.id,
    ...(document.data() as WalletHistoryTransaction),
  }));
};
