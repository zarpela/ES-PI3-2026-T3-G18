/*
Autor: [COLOQUE SEU NOME COMPLETO]
RA: [COLOQUE SEU RA]
*/

import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {db} from "../shared/firebase";

type WalletAccessInput = {
  authenticatedUserId?: string;
  historyLimit?: number | string;
  userId?: string;
};

type CreateWalletInput = WalletAccessInput;

type DepositInput = WalletAccessInput & {
  amount?: number | string;
};

type WithdrawInput = WalletAccessInput & {
  amount?: number | string;
};

type BuyTokenInput = WalletAccessInput & {
  price?: number | string;
  quantity?: number | string;
  startupId?: string;
  startupName?: string;
  startupSymbol?: string;
  unitPrice?: number | string;
};

type SellTokenInput = WalletAccessInput & {
  price?: number | string;
  quantity?: number | string;
  startupId?: string;
  unitPrice?: number | string;
};

type WalletDocument = {
  balance: number;
  createdAt: Timestamp | FieldValue;
  totalCurrentValue: number;
  totalInvested: number;
  totalProfitLoss: number;
  totalProfitLossPercent: number;
  updatedAt: Timestamp | FieldValue;
  userId: string;
};

type WalletTokenDocument = {
  averagePrice: number;
  currentPrice: number;
  currentValue: number;
  lastTransactionAt: Timestamp | FieldValue;
  profitLoss: number;
  profitLossPercent: number;
  quantity: number;
  startupId: string;
  startupName: string;
  startupSymbol: string;
  totalInvested: number;
  updatedAt: Timestamp | FieldValue;
};

type WalletTransactionType = "DEPOSIT" | "WITHDRAW" | "BUY" | "SELL";

type WalletTransactionDocument = {
  balanceAfter: number;
  balanceBefore: number;
  createdAt: Timestamp | FieldValue;
  description: string;
  quantity: number;
  startupId: string | null;
  startupName: string | null;
  startupSymbol: string | null;
  totalAmount: number;
  type: WalletTransactionType;
  unitPrice: number;
};

type ServiceError = Error & {
  status?: number;
};

type WalletSummary = {
  totalCurrentValue: number;
  totalInvested: number;
  totalProfitLoss: number;
  totalProfitLossPercent: number;
};

type WalletRecord = Omit<WalletDocument, "createdAt" | "updatedAt"> & {
  createdAt: unknown;
  updatedAt: unknown;
};

type WalletTokenRecord = Omit<
  WalletTokenDocument,
  "lastTransactionAt" | "updatedAt"
> & {
  lastTransactionAt: unknown;
  updatedAt: unknown;
};

type SerializedWalletToken = {
  averagePrice: number;
  currentPrice: number;
  currentValue: number;
  lastTransactionAt: string | null;
  profitLoss: number;
  profitLossPercent: number;
  quantity: number;
  startupId: string;
  startupName: string;
  startupSymbol: string;
  totalInvested: number;
  updatedAt: string | null;
};

type SerializedWalletTransaction = {
  balanceAfter: number;
  balanceBefore: number;
  createdAt: string | null;
  description: string;
  id: string;
  quantity: number;
  startupId: string | null;
  startupName: string | null;
  startupSymbol: string | null;
  totalAmount: number;
  type: WalletTransactionType;
  unitPrice: number;
};

type SerializedWallet = {
  balance: number;
  createdAt: string | null;
  portfolioTotal: number;
  recentTransactions: SerializedWalletTransaction[];
  tokens: SerializedWalletToken[];
  totalCurrentValue: number;
  totalInvested: number;
  totalProfitLoss: number;
  totalProfitLossPercent: number;
  updatedAt: string | null;
  userId: string;
};

type WalletOverview = {
  recentTransactions: SerializedWalletTransaction[];
  tokens: SerializedWalletToken[];
  wallet: SerializedWallet;
};

type LegacyWalletToken = {
  averagePrice?: number | string;
  quantity?: number | string;
  startupId?: string;
  startupName?: string;
};

type LegacyWalletDocument = {
  balance?: number | string;
  createdAt?: unknown;
  lastUpdated?: unknown;
  tokens?: unknown;
  updatedAt?: unknown;
};

const walletCollection = "wallet";
const legacyWalletCollection = "wallets";
const walletTokensCollection = "tokens";
const walletTransactionsCollection = "transactions";
const startupsCollection = "startups";
const defaultHistoryLimit = 20;
const unauthorizedMessage = "Usuario nao autenticado.";
const forbiddenMessage = "Voce nao tem permissao para acessar esta carteira.";

function createServiceError(status: number, message: string): ServiceError {
  const error = new Error(message) as ServiceError;
  error.status = status;
  return error;
}

function normalizeString(value: unknown): string {
  return String(value ?? "").trim();
}

function resolveAuthorizedUserId(data: WalletAccessInput): string {
  const authenticatedUserId = normalizeString(data.authenticatedUserId);
  const requestedUserId = normalizeString(data.userId);

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

  return roundCurrency(parsedValue);
}

function parseHistoryLimit(value: number | string | undefined): number {
  const parsedValue = parseNumber(value);

  if (!Number.isFinite(parsedValue) || parsedValue <= 0) {
    return defaultHistoryLimit;
  }

  return Math.max(1, Math.min(defaultHistoryLimit, Math.trunc(parsedValue)));
}

function roundCurrency(value: number): number {
  return Number(value.toFixed(2));
}

function roundPercent(value: number): number {
  return Number(value.toFixed(4));
}

function isTimestamp(value: unknown): value is Timestamp {
  return value instanceof Timestamp;
}

function serializeTimestamp(value: unknown): string | null {
  if (isTimestamp(value)) {
    return value.toDate().toISOString();
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  if (typeof value === "string" && value.trim()) {
    const parsedDate = new Date(value);
    return Number.isNaN(parsedDate.getTime()) ? value : parsedDate.toISOString();
  }

  if (
    value &&
    typeof value === "object" &&
    "toDate" in value &&
    typeof (value as {toDate: () => Date}).toDate === "function"
  ) {
    return (value as {toDate: () => Date}).toDate().toISOString();
  }

  return null;
}

function coerceTimestampForWrite(value: unknown): Timestamp | FieldValue {
  if (isTimestamp(value)) {
    return value;
  }

  if (value instanceof Date) {
    return Timestamp.fromDate(value);
  }

  if (typeof value === "string" && value.trim()) {
    const parsedDate = new Date(value);

    if (!Number.isNaN(parsedDate.getTime())) {
      return Timestamp.fromDate(parsedDate);
    }
  }

  if (
    value &&
    typeof value === "object" &&
    "toDate" in value &&
    typeof (value as {toDate: () => Date}).toDate === "function"
  ) {
    return Timestamp.fromDate((value as {toDate: () => Date}).toDate());
  }

  return FieldValue.serverTimestamp();
}

function calculateTokenMetrics(
  quantity: number,
  averagePrice: number,
  currentPrice: number,
) {
  const totalInvested = roundCurrency(quantity * averagePrice);
  const currentValue = roundCurrency(quantity * currentPrice);
  const profitLoss = roundCurrency(currentValue - totalInvested);
  const profitLossPercent = totalInvested > 0 ?
    roundPercent((profitLoss / totalInvested) * 100) :
    0;

  return {
    totalInvested,
    currentValue,
    profitLoss,
    profitLossPercent,
  };
}

function buildTokenDocument(data: {
  averagePrice: number;
  currentPrice: number;
  quantity: number;
  startupId: string;
  startupName: string;
  startupSymbol: string;
}): WalletTokenDocument {
  const quantity = roundCurrency(data.quantity);
  const averagePrice = roundCurrency(data.averagePrice);
  const currentPrice = roundCurrency(data.currentPrice);
  const metrics = calculateTokenMetrics(quantity, averagePrice, currentPrice);

  return {
    startupId: data.startupId,
    startupName: data.startupName,
    startupSymbol: data.startupSymbol,
    quantity,
    averagePrice,
    currentPrice,
    totalInvested: metrics.totalInvested,
    currentValue: metrics.currentValue,
    profitLoss: metrics.profitLoss,
    profitLossPercent: metrics.profitLossPercent,
    lastTransactionAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

function calculateWalletSummary(
  tokens: Array<Pick<WalletTokenRecord, "currentValue" | "totalInvested">>,
): WalletSummary {
  const totalInvested = roundCurrency(
    tokens.reduce((sum, token) => sum + token.totalInvested, 0),
  );
  const totalCurrentValue = roundCurrency(
    tokens.reduce((sum, token) => sum + token.currentValue, 0),
  );
  const totalProfitLoss = roundCurrency(totalCurrentValue - totalInvested);
  const totalProfitLossPercent = totalInvested > 0 ?
    roundPercent((totalProfitLoss / totalInvested) * 100) :
    0;

  return {
    totalInvested,
    totalCurrentValue,
    totalProfitLoss,
    totalProfitLossPercent,
  };
}

function areEqualNumbers(left: number, right: number): boolean {
  return Math.abs(left - right) < 0.0001;
}

function normalizeWalletDocument(
  userId: string,
  data: Partial<WalletDocument> | undefined,
): WalletRecord {
  return {
    userId,
    balance: roundCurrency(Number(data?.balance ?? 0)),
    totalInvested: roundCurrency(Number(data?.totalInvested ?? 0)),
    totalCurrentValue: roundCurrency(Number(data?.totalCurrentValue ?? 0)),
    totalProfitLoss: roundCurrency(Number(data?.totalProfitLoss ?? 0)),
    totalProfitLossPercent: roundPercent(
      Number(data?.totalProfitLossPercent ?? 0),
    ),
    createdAt: data?.createdAt,
    updatedAt: data?.updatedAt,
  };
}

function normalizeWalletTokenDocument(
  startupId: string,
  data: Partial<WalletTokenDocument> | undefined,
): WalletTokenRecord {
  const normalizedStartupId = normalizeString(data?.startupId) || startupId;
  const startupName = normalizeString(data?.startupName) || normalizedStartupId;
  const startupSymbol = normalizeString(data?.startupSymbol) ||
    deriveStartupSymbol(normalizedStartupId, startupName);
  const quantity = roundCurrency(Number(data?.quantity ?? 0));
  const averagePrice = roundCurrency(Number(data?.averagePrice ?? 0));
  const currentPrice = roundCurrency(Number(data?.currentPrice ?? averagePrice));
  const metrics = calculateTokenMetrics(quantity, averagePrice, currentPrice);

  return {
    startupId: normalizedStartupId,
    startupName,
    startupSymbol,
    quantity,
    averagePrice,
    currentPrice,
    totalInvested: roundCurrency(
      Number(data?.totalInvested ?? metrics.totalInvested),
    ),
    currentValue: roundCurrency(
      Number(data?.currentValue ?? metrics.currentValue),
    ),
    profitLoss: roundCurrency(Number(data?.profitLoss ?? metrics.profitLoss)),
    profitLossPercent: roundPercent(
      Number(data?.profitLossPercent ?? metrics.profitLossPercent),
    ),
    lastTransactionAt: data?.lastTransactionAt ?? null,
    updatedAt: data?.updatedAt ?? null,
  };
}

function normalizeWalletTransactionDocument(
  id: string,
  data: Partial<WalletTransactionDocument> | undefined,
): SerializedWalletTransaction {
  return {
    id,
    type: (data?.type ?? "DEPOSIT") as WalletTransactionType,
    startupId: data?.startupId ?? null,
    startupName: data?.startupName ?? null,
    startupSymbol: data?.startupSymbol ?? null,
    quantity: roundCurrency(Number(data?.quantity ?? 0)),
    unitPrice: roundCurrency(Number(data?.unitPrice ?? 0)),
    totalAmount: roundCurrency(Number(data?.totalAmount ?? 0)),
    balanceBefore: roundCurrency(Number(data?.balanceBefore ?? 0)),
    balanceAfter: roundCurrency(Number(data?.balanceAfter ?? 0)),
    createdAt: serializeTimestamp(data?.createdAt),
    description: normalizeString(data?.description),
  };
}

function serializeWalletToken(token: WalletTokenRecord): SerializedWalletToken {
  return {
    startupId: token.startupId,
    startupName: token.startupName,
    startupSymbol: token.startupSymbol,
    quantity: token.quantity,
    averagePrice: token.averagePrice,
    currentPrice: token.currentPrice,
    totalInvested: token.totalInvested,
    currentValue: token.currentValue,
    profitLoss: token.profitLoss,
    profitLossPercent: token.profitLossPercent,
    lastTransactionAt: serializeTimestamp(token.lastTransactionAt),
    updatedAt: serializeTimestamp(token.updatedAt),
  };
}

function normalizeLegacyTokens(tokens: unknown): LegacyWalletToken[] {
  if (!Array.isArray(tokens)) {
    return [];
  }

  return tokens
    .map((token) => token as LegacyWalletToken)
    .filter((token) => normalizeString(token.startupId));
}

function deriveStartupSymbol(
  startupId: string,
  startupName: string,
  providedSymbol?: string,
  startupData?: Record<string, unknown>,
): string {
  const candidate = normalizeString(providedSymbol) ||
    normalizeString(startupData?.startupSymbol) ||
    normalizeString(startupData?.symbol) ||
    normalizeString(startupData?.ticker);

  if (candidate) {
    return candidate.toUpperCase();
  }

  const words = startupName
    .toUpperCase()
    .replace(/[^A-Z0-9\s]/g, " ")
    .split(/\s+/)
    .filter(Boolean);

  if (words.length >= 2) {
    return words.slice(0, 4).map((word) => word[0]).join("");
  }

  const sanitizedName = startupName
    .toUpperCase()
    .replace(/[^A-Z0-9]/g, "");

  if (sanitizedName.length >= 4) {
    return sanitizedName.slice(0, 4);
  }

  return startupId.toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 6) || "TOKN";
}

function getStartupName(
  startupId: string,
  providedName?: string,
  startupData?: Record<string, unknown>,
): string {
  return normalizeString(providedName) ||
    normalizeString(startupData?.startupName) ||
    normalizeString(startupData?.name) ||
    normalizeString(startupData?.nome) ||
    startupId;
}

function getWalletRef(userId: string) {
  return db.collection(walletCollection).doc(userId);
}

function getLegacyWalletRef(userId: string) {
  return db.collection(legacyWalletCollection).doc(userId);
}

function getWalletTokensRef(userId: string) {
  return getWalletRef(userId).collection(walletTokensCollection);
}

function getWalletTokenRef(userId: string, startupId: string) {
  return getWalletTokensRef(userId).doc(startupId);
}

function getWalletTransactionsRef(userId: string) {
  return getWalletRef(userId).collection(walletTransactionsCollection);
}

async function ensureWalletDocument(userId: string): Promise<void> {
  await db.runTransaction(async (transaction) => {
    const walletRef = getWalletRef(userId);
    const walletSnapshot = await transaction.get(walletRef);

    if (walletSnapshot.exists) {
      return;
    }

    const legacyWalletSnapshot = await transaction.get(getLegacyWalletRef(userId));

    if (legacyWalletSnapshot.exists) {
      const legacyWalletData = legacyWalletSnapshot.data() as LegacyWalletDocument;
      const legacyTokens = normalizeLegacyTokens(legacyWalletData.tokens);
      const migratedTokens = legacyTokens.map((token) => buildTokenDocument({
        startupId: normalizeString(token.startupId),
        startupName: normalizeString(token.startupName) ||
          normalizeString(token.startupId),
        startupSymbol: deriveStartupSymbol(
          normalizeString(token.startupId),
          normalizeString(token.startupName) || normalizeString(token.startupId),
        ),
        quantity: roundCurrency(Number(token.quantity ?? 0)),
        averagePrice: roundCurrency(Number(token.averagePrice ?? 0)),
        currentPrice: roundCurrency(Number(token.averagePrice ?? 0)),
      }));
      const summary = calculateWalletSummary(migratedTokens);

      transaction.set(walletRef, {
        userId,
        balance: roundCurrency(Number(legacyWalletData.balance ?? 0)),
        totalInvested: summary.totalInvested,
        totalCurrentValue: summary.totalCurrentValue,
        totalProfitLoss: summary.totalProfitLoss,
        totalProfitLossPercent: summary.totalProfitLossPercent,
        createdAt: coerceTimestampForWrite(legacyWalletData.createdAt),
        updatedAt: coerceTimestampForWrite(
          legacyWalletData.updatedAt ?? legacyWalletData.lastUpdated,
        ),
      } satisfies WalletDocument);

      for (const token of migratedTokens) {
        transaction.set(getWalletTokenRef(userId, token.startupId), {
          ...token,
          lastTransactionAt: coerceTimestampForWrite(
            legacyWalletData.updatedAt ??
              legacyWalletData.lastUpdated ??
              legacyWalletData.createdAt,
          ),
          updatedAt: coerceTimestampForWrite(
            legacyWalletData.updatedAt ??
              legacyWalletData.lastUpdated ??
              legacyWalletData.createdAt,
          ),
        } satisfies WalletTokenDocument);
      }

      return;
    }

    // O userId como id do documento garante unicidade da carteira por usuario.
    // Abdallah ajustou a integracao com a carteira simulada no novo formato.
    transaction.set(walletRef, {
      userId,
      balance: 0,
      totalInvested: 0,
      totalCurrentValue: 0,
      totalProfitLoss: 0,
      totalProfitLossPercent: 0,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    } satisfies WalletDocument);
  });
}

async function syncWalletSummary(userId: string): Promise<void> {
  const walletRef = getWalletRef(userId);
  const [walletSnapshot, tokensSnapshot] = await Promise.all([
    walletRef.get(),
    getWalletTokensRef(userId).get(),
  ]);

  if (!walletSnapshot.exists) {
    throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
  }

  const normalizedWallet = normalizeWalletDocument(
    userId,
    walletSnapshot.data() as Partial<WalletDocument>,
  );
  const normalizedTokens = tokensSnapshot.docs.map((document) =>
    normalizeWalletTokenDocument(
      document.id,
      document.data() as Partial<WalletTokenDocument>,
    ),
  );
  const summary = calculateWalletSummary(normalizedTokens);

  if (
    areEqualNumbers(normalizedWallet.totalInvested, summary.totalInvested) &&
    areEqualNumbers(
      normalizedWallet.totalCurrentValue,
      summary.totalCurrentValue,
    ) &&
    areEqualNumbers(normalizedWallet.totalProfitLoss, summary.totalProfitLoss) &&
    areEqualNumbers(
      normalizedWallet.totalProfitLossPercent,
      summary.totalProfitLossPercent,
    )
  ) {
    return;
  }

  await walletRef.set({
    totalInvested: summary.totalInvested,
    totalCurrentValue: summary.totalCurrentValue,
    totalProfitLoss: summary.totalProfitLoss,
    totalProfitLossPercent: summary.totalProfitLossPercent,
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge: true});
}

async function buildWalletOverview(
  userId: string,
  historyLimit: number,
): Promise<WalletOverview> {
  const walletRef = getWalletRef(userId);
  const [walletSnapshot, tokensSnapshot, transactionsSnapshot] = await Promise.all([
    walletRef.get(),
    getWalletTokensRef(userId).orderBy("updatedAt", "desc").get(),
    getWalletTransactionsRef(userId)
      .orderBy("createdAt", "desc")
      .limit(historyLimit)
      .get(),
  ]);

  if (!walletSnapshot.exists) {
    throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
  }

  const normalizedWallet = normalizeWalletDocument(
    userId,
    walletSnapshot.data() as Partial<WalletDocument>,
  );
  const normalizedTokens = tokensSnapshot.docs.map((document) =>
    normalizeWalletTokenDocument(
      document.id,
      document.data() as Partial<WalletTokenDocument>,
    ),
  );
  const summary = calculateWalletSummary(normalizedTokens);
  const tokens = normalizedTokens.map(serializeWalletToken);
  const recentTransactions = transactionsSnapshot.docs.map((document) =>
    normalizeWalletTransactionDocument(
      document.id,
      document.data() as Partial<WalletTransactionDocument>,
    ),
  );
  const wallet: SerializedWallet = {
    userId,
    balance: normalizedWallet.balance,
    totalInvested: summary.totalInvested,
    totalCurrentValue: summary.totalCurrentValue,
    totalProfitLoss: summary.totalProfitLoss,
    totalProfitLossPercent: summary.totalProfitLossPercent,
    portfolioTotal: roundCurrency(
      normalizedWallet.balance + summary.totalCurrentValue,
    ),
    createdAt: serializeTimestamp(normalizedWallet.createdAt),
    updatedAt: serializeTimestamp(normalizedWallet.updatedAt),
    tokens,
    recentTransactions,
  };

  return {
    wallet,
    tokens,
    recentTransactions,
  };
}

function buildTransactionDocument(data: {
  balanceAfter: number;
  balanceBefore: number;
  description: string;
  quantity: number;
  startupId: string | null;
  startupName: string | null;
  startupSymbol: string | null;
  totalAmount: number;
  type: WalletTransactionType;
  unitPrice: number;
}): WalletTransactionDocument {
  return {
    type: data.type,
    startupId: data.startupId,
    startupName: data.startupName,
    startupSymbol: data.startupSymbol,
    quantity: roundCurrency(data.quantity),
    unitPrice: roundCurrency(data.unitPrice),
    totalAmount: roundCurrency(data.totalAmount),
    balanceBefore: roundCurrency(data.balanceBefore),
    balanceAfter: roundCurrency(data.balanceAfter),
    createdAt: FieldValue.serverTimestamp(),
    description: data.description,
  };
}

export const createWallet = async (data: CreateWalletInput) => {
  const userId = resolveAuthorizedUserId(data);
  const historyLimit = parseHistoryLimit(data.historyLimit);

  await ensureWalletDocument(userId);
  await syncWalletSummary(userId);

  return buildWalletOverview(userId, historyLimit);
};

export const getWalletByUserId = async (data: WalletAccessInput) => {
  const userId = resolveAuthorizedUserId(data);
  const historyLimit = parseHistoryLimit(data.historyLimit);

  await ensureWalletDocument(userId);
  await syncWalletSummary(userId);

  return buildWalletOverview(userId, historyLimit);
};

export const addBalanceToWallet = async (data: DepositInput) => {
  const userId = resolveAuthorizedUserId(data);
  const amount = parsePositiveNumber(data.amount, "amount");
  const historyLimit = parseHistoryLimit(data.historyLimit);
  const walletRef = getWalletRef(userId);
  const transactionRef = getWalletTransactionsRef(userId).doc();

  await ensureWalletDocument(userId);

  await db.runTransaction(async (transaction) => {
    const walletSnapshot = await transaction.get(walletRef);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    const wallet = normalizeWalletDocument(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const balanceBefore = wallet.balance;
    const balanceAfter = roundCurrency(balanceBefore + amount);

    transaction.set(walletRef, {
      balance: balanceAfter,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(transactionRef, buildTransactionDocument({
      type: "DEPOSIT",
      startupId: null,
      startupName: null,
      startupSymbol: null,
      quantity: 0,
      unitPrice: 0,
      totalAmount: amount,
      balanceBefore,
      balanceAfter,
      description: "Deposito simulado",
    }));
  });

  await syncWalletSummary(userId);
  return buildWalletOverview(userId, historyLimit);
};

export const withdrawBalanceFromWallet = async (data: WithdrawInput) => {
  const userId = resolveAuthorizedUserId(data);
  const amount = parsePositiveNumber(data.amount, "amount");
  const historyLimit = parseHistoryLimit(data.historyLimit);
  const walletRef = getWalletRef(userId);
  const transactionRef = getWalletTransactionsRef(userId).doc();

  await ensureWalletDocument(userId);

  await db.runTransaction(async (transaction) => {
    const walletSnapshot = await transaction.get(walletRef);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    const wallet = normalizeWalletDocument(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );

    if (wallet.balance < amount) {
      throw createServiceError(400, "Saldo insuficiente");
    }

    const balanceBefore = wallet.balance;
    const balanceAfter = roundCurrency(balanceBefore - amount);

    transaction.set(walletRef, {
      balance: balanceAfter,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(transactionRef, buildTransactionDocument({
      type: "WITHDRAW",
      startupId: null,
      startupName: null,
      startupSymbol: null,
      quantity: 0,
      unitPrice: 0,
      totalAmount: amount,
      balanceBefore,
      balanceAfter,
      description: "Saque simulado",
    }));
  });

  await syncWalletSummary(userId);
  return buildWalletOverview(userId, historyLimit);
};

export const buyStartupTokens = async (data: BuyTokenInput) => {
  const userId = resolveAuthorizedUserId(data);
  const startupId = normalizeString(data.startupId);
  const quantity = parsePositiveNumber(data.quantity, "quantity");
  const unitPrice = parsePositiveNumber(
    data.unitPrice ?? data.price,
    "unitPrice",
  );
  const historyLimit = parseHistoryLimit(data.historyLimit);
  const walletRef = getWalletRef(userId);
  const tokenRef = getWalletTokenRef(userId, startupId);
  const transactionRef = getWalletTransactionsRef(userId).doc();

  if (!startupId) {
    throw createServiceError(400, "startupId e obrigatorio.");
  }

  await ensureWalletDocument(userId);

  await db.runTransaction(async (transaction) => {
    const [walletSnapshot, tokenSnapshot, startupSnapshot] = await Promise.all([
      transaction.get(walletRef),
      transaction.get(tokenRef),
      transaction.get(db.collection(startupsCollection).doc(startupId)),
    ]);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    if (!startupSnapshot.exists) {
      throw createServiceError(404, "Startup invalida.");
    }

    const wallet = normalizeWalletDocument(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const startupData = startupSnapshot.data() as Record<string, unknown>;
    const startupName = getStartupName(startupId, data.startupName, startupData);
    const startupSymbol = deriveStartupSymbol(
      startupId,
      startupName,
      data.startupSymbol,
      startupData,
    );
    const totalAmount = roundCurrency(quantity * unitPrice);

    if (wallet.balance < totalAmount) {
      throw createServiceError(400, "Saldo insuficiente");
    }

    const existingToken = tokenSnapshot.exists ?
      normalizeWalletTokenDocument(
        tokenSnapshot.id,
        tokenSnapshot.data() as Partial<WalletTokenDocument>,
      ) :
      null;
    const existingQuantity = existingToken?.quantity ?? 0;
    const existingAveragePrice = existingToken?.averagePrice ?? 0;
    const updatedQuantity = roundCurrency(existingQuantity + quantity);
    const updatedAveragePrice = updatedQuantity > 0 ?
      roundCurrency(
        ((existingQuantity * existingAveragePrice) + (quantity * unitPrice)) /
          updatedQuantity,
      ) :
      0;
    const updatedToken = buildTokenDocument({
      startupId,
      startupName,
      startupSymbol,
      quantity: updatedQuantity,
      averagePrice: updatedAveragePrice,
      currentPrice: unitPrice,
    });
    const balanceBefore = wallet.balance;
    const balanceAfter = roundCurrency(balanceBefore - totalAmount);

    transaction.set(walletRef, {
      balance: balanceAfter,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(tokenRef, updatedToken);
    transaction.set(transactionRef, buildTransactionDocument({
      type: "BUY",
      startupId,
      startupName,
      startupSymbol,
      quantity,
      unitPrice,
      totalAmount,
      balanceBefore,
      balanceAfter,
      description: `Compra simulada de tokens da startup ${startupName}`,
    }));
  });

  await syncWalletSummary(userId);
  return buildWalletOverview(userId, historyLimit);
};

export const sellStartupTokens = async (data: SellTokenInput) => {
  const userId = resolveAuthorizedUserId(data);
  const startupId = normalizeString(data.startupId);
  const quantity = parsePositiveNumber(data.quantity, "quantity");
  const unitPrice = parsePositiveNumber(
    data.unitPrice ?? data.price,
    "unitPrice",
  );
  const historyLimit = parseHistoryLimit(data.historyLimit);
  const walletRef = getWalletRef(userId);
  const tokenRef = getWalletTokenRef(userId, startupId);
  const transactionRef = getWalletTransactionsRef(userId).doc();

  if (!startupId) {
    throw createServiceError(400, "startupId e obrigatorio.");
  }

  await ensureWalletDocument(userId);

  await db.runTransaction(async (transaction) => {
    const [walletSnapshot, tokenSnapshot] = await Promise.all([
      transaction.get(walletRef),
      transaction.get(tokenRef),
    ]);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    if (!tokenSnapshot.exists) {
      throw createServiceError(400, "Quantidade de tokens insuficiente");
    }

    const wallet = normalizeWalletDocument(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const token = normalizeWalletTokenDocument(
      tokenSnapshot.id,
      tokenSnapshot.data() as Partial<WalletTokenDocument>,
    );

    if (token.quantity < quantity) {
      throw createServiceError(400, "Quantidade de tokens insuficiente");
    }

    const remainingQuantity = roundCurrency(token.quantity - quantity);
    const totalAmount = roundCurrency(quantity * unitPrice);
    const balanceBefore = wallet.balance;
    const balanceAfter = roundCurrency(balanceBefore + totalAmount);

    transaction.set(walletRef, {
      balance: balanceAfter,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});

    if (remainingQuantity === 0) {
      // Abdallah ajustou esta parte para remover o documento zerado.
      // Isso evita tokens fantasmas e simplifica os calculos da carteira.
      transaction.delete(tokenRef);
    } else {
      transaction.set(tokenRef, buildTokenDocument({
        startupId: token.startupId,
        startupName: token.startupName,
        startupSymbol: token.startupSymbol,
        quantity: remainingQuantity,
        averagePrice: token.averagePrice,
        currentPrice: unitPrice,
      }));
    }

    transaction.set(transactionRef, buildTransactionDocument({
      type: "SELL",
      startupId: token.startupId,
      startupName: token.startupName,
      startupSymbol: token.startupSymbol,
      quantity,
      unitPrice,
      totalAmount,
      balanceBefore,
      balanceAfter,
      description: `Venda simulada de tokens da startup ${token.startupName}`,
    }));
  });

  await syncWalletSummary(userId);
  return buildWalletOverview(userId, historyLimit);
};

export const listWalletTokens = async (data: WalletAccessInput) => {
  const overview = await getWalletByUserId(data);
  return overview.tokens;
};

export const getWalletTransactionHistory = async (data: WalletAccessInput) => {
  const userId = resolveAuthorizedUserId(data);
  const historyLimit = parseHistoryLimit(data.historyLimit);

  await ensureWalletDocument(userId);

  const transactionsSnapshot = await getWalletTransactionsRef(userId)
    .orderBy("createdAt", "desc")
    .limit(historyLimit)
    .get();

  return transactionsSnapshot.docs.map((document) =>
    normalizeWalletTransactionDocument(
      document.id,
      document.data() as Partial<WalletTransactionDocument>,
    ),
  );
};
