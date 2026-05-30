//feito por Abdallah
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

type SellOfferInput = WalletAccessInput & {
  price?: number | string;
  quantity?: number | string;
  startupId?: string;
  startupName?: string;
  startupSymbol?: string;
  unitPrice?: number | string;
};

type BuyMarketplaceOfferInput = WalletAccessInput & {
  offerId?: string;
  quantity?: number | string;
};

type UpdateMarketplaceOfferInput = WalletAccessInput & {
  offerId?: string;
  quantity?: number | string;
  unitPrice?: number | string;
  price?: number | string;
};

type MarketplaceOffersInput = {
  stage?: string;
  startupId?: string;
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

type WalletHoldingDocument = {
  averagePrice: number;
  currentPrice: number;
  currentValue: number;
  lastTransactionAt: Timestamp | FieldValue;
  profitLoss: number;
  profitLossPercent: number;
  quantity: number;
  reservedQuantity: number;
  startupId: string;
  startupName: string;
  startupSymbol: string;
  totalInvested: number;
  updatedAt: Timestamp | FieldValue;
  userId: string;
};

type WalletTransactionType =
  | "DEPOSIT"
  | "WITHDRAW"
  | "BUY"
  | "SELL_OFFER_CREATED"
  | "BUY_MARKETPLACE"
  | "SELL_MARKETPLACE"
  | "OFFER_CANCELLED"
  | "OFFER_UPDATED";

type WalletTransactionDocument = {
  balanceAfter: number;
  balanceBefore: number;
  createdAt: Timestamp | FieldValue;
  description: string;
  offerId: string | null;
  quantity: number;
  relatedUserId: string | null;
  startupId: string | null;
  startupName: string | null;
  startupSymbol: string | null;
  status: string;
  tokensAfter: number;
  tokensBefore: number;
  totalAmount: number;
  totalValue: number;
  type: WalletTransactionType;
  unitPrice: number;
  userId: string;
};

type MarketplaceOfferStatus = "open" | "partial" | "closed" | "cancelled";

type MarketplaceOfferDocument = {
  createdAt: Timestamp | FieldValue;
  id: string;
  price: number;
  pricePerToken: number;
  quantity: number;
  remainingQuantity: number;
  sellerId: string;
  sellerName: string;
  startupId: string;
  startupName: string;
  startupStage: string | null;
  status: MarketplaceOfferStatus;
  totalValue: number;
  type: "sell";
  unitPrice: number;
  updatedAt: Timestamp | FieldValue;
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

type WalletHoldingRecord = Omit<
  WalletHoldingDocument,
  "lastTransactionAt" | "updatedAt"
> & {
  lastTransactionAt: unknown;
  updatedAt: unknown;
};

type SerializedWalletHolding = {
  averagePrice: number;
  availableQuantity: number;
  currentPrice: number;
  currentValue: number;
  lastTransactionAt: string | null;
  profitLoss: number;
  profitLossPercent: number;
  quantity: number;
  reservedQuantity: number;
  startupId: string;
  startupName: string;
  startupSymbol: string;
  totalInvested: number;
  updatedAt: string | null;
};

type SerializedWalletTransaction = {
  amount: number;
  balanceAfter: number;
  balanceBefore: number;
  createdAt: string | null;
  description: string;
  id: string;
  offerId: string | null;
  quantity: number;
  relatedUserId: string | null;
  startupId: string | null;
  startupName: string | null;
  startupSymbol: string | null;
  status: string;
  tokensAfter: number;
  tokensBefore: number;
  total: number;
  totalAmount: number;
  totalValue: number;
  type: WalletTransactionType;
  unitPrice: number;
  userId: string;
};

type SerializedWallet = {
  balance: number;
  createdAt: string | null;
  holdings: SerializedWalletHolding[];
  portfolioTotal: number;
  recentTransactions: SerializedWalletTransaction[];
  tokens: SerializedWalletHolding[];
  totalCurrentValue: number;
  totalInvested: number;
  totalProfitLoss: number;
  totalProfitLossPercent: number;
  updatedAt: string | null;
  userId: string;
};

type WalletOverview = {
  holdings: SerializedWalletHolding[];
  recentTransactions: SerializedWalletTransaction[];
  tokens: SerializedWalletHolding[];
  wallet: SerializedWallet;
};

type SerializedMarketplaceOffer = {
  amount: number;
  createdAt: string | null;
  id: string;
  ownerId: string;
  price: number;
  pricePerToken: number;
  quantity: number;
  remainingQuantity: number;
  sellerId: string;
  sellerName: string;
  startupId: string;
  startupName: string;
  startupStage: string | null;
  status: MarketplaceOfferStatus;
  title: string;
  totalValue: number;
  type: "sell";
  unitPrice: number;
  updatedAt: string | null;
};

type StartupRecord = Record<string, unknown>;

type StartupLookupFallback = {
  startupName?: string;
  startupSymbol?: string;
  unitPrice?: number | string;
};

type LegacyWalletToken = {
  amount?: number | string;
  averagePrice?: number | string;
  currentPrice?: number | string;
  quantity?: number | string;
  reservedQuantity?: number | string;
  startupId?: string;
  startupName?: string;
  startupSymbol?: string;
  symbol?: string;
};

type LegacyWalletDocument = {
  balance?: number | string;
  createdAt?: unknown;
  lastUpdated?: unknown;
  tokens?: unknown;
  updatedAt?: unknown;
};

type LegacyWalletData = {
  balance: number;
  createdAt?: unknown;
  holdings: WalletHoldingRecord[];
  updatedAt?: unknown;
};

const walletCollection = "wallets";
const legacyWalletCollection = "wallet";
const legacyPluralWalletCollection = "wallets";
const walletHoldingsCollection = "holdings";
const walletLegacyTokensCollection = "tokens";
const walletTransactionsCollection = "transactions";
const marketplaceOffersCollection = "marketplaceOffers";
const startupsCollection = "startups";
const usersCollection = "users";
const defaultHistoryLimit = 20;
const unauthorizedMessage = "Usuario nao autenticado.";
const forbiddenMessage = "Voce nao tem permissao para acessar esta carteira.";

export function createServiceError(
  status: number,
  message: string,
): ServiceError {
  const error = new Error(message) as ServiceError;
  error.status = status;
  return error;
}

function normalizeString(value: unknown): string {
  return String(value ?? "").trim();
}

function normalizeStage(value: unknown): string {
  return normalizeString(value).toLowerCase().replace(/\s+/g, "_");
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
    const raw = value.trim();
    const normalized = raw.includes(",") ?
      raw.replace(/\./g, "").replace(",", ".") :
      raw.replace(/,/g, "");

    return Number(normalized.replace(/[^0-9.-]/g, ""));
  }

  return Number.NaN;
}

function parsePositiveCurrency(
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

function parsePositiveQuantity(
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

  if (!Number.isInteger(parsedValue)) {
    throw createServiceError(400, `${fieldName} deve ser um numero inteiro.`);
  }

  return parsedValue;
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

function calculateHoldingMetrics(
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
    currentValue,
    profitLoss,
    profitLossPercent,
    totalInvested,
  };
}

function buildHoldingDocument(data: {
  averagePrice: number;
  currentPrice: number;
  quantity: number;
  reservedQuantity?: number;
  startupId: string;
  startupName: string;
  startupSymbol: string;
  userId: string;
}): WalletHoldingDocument {
  const quantity = Math.max(0, Math.trunc(data.quantity));
  const reservedQuantity = Math.max(
    0,
    Math.min(quantity, Math.trunc(data.reservedQuantity ?? 0)),
  );
  const averagePrice = roundCurrency(data.averagePrice);
  const currentPrice = roundCurrency(data.currentPrice);
  const metrics = calculateHoldingMetrics(quantity, averagePrice, currentPrice);

  return {
    userId: data.userId,
    startupId: data.startupId,
    startupName: data.startupName,
    startupSymbol: data.startupSymbol,
    quantity,
    reservedQuantity,
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
  holdings: Array<Pick<WalletHoldingRecord, "currentValue" | "totalInvested">>,
): WalletSummary {
  const totalInvested = roundCurrency(
    holdings.reduce((sum, holding) => sum + holding.totalInvested, 0),
  );
  const totalCurrentValue = roundCurrency(
    holdings.reduce((sum, holding) => sum + holding.currentValue, 0),
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

function normalizeWalletHoldingDocument(
  startupId: string,
  userId: string,
  data: Partial<WalletHoldingDocument & LegacyWalletToken> | undefined,
): WalletHoldingRecord {
  const normalizedStartupId = normalizeString(data?.startupId) || startupId;
  const startupName = normalizeString(data?.startupName) || normalizedStartupId;
  const startupSymbol = normalizeString(data?.startupSymbol) ||
    normalizeString(data?.symbol) ||
    deriveStartupSymbol(normalizedStartupId, startupName);
  const quantity = Math.max(
    0,
    Math.trunc(Number(data?.quantity ?? data?.amount ?? 0)),
  );
  const reservedQuantity = Math.max(
    0,
    Math.min(quantity, Math.trunc(Number(data?.reservedQuantity ?? 0))),
  );
  const averagePrice = roundCurrency(Number(data?.averagePrice ?? 0));
  const currentPrice = roundCurrency(Number(data?.currentPrice ?? averagePrice));
  const metrics = calculateHoldingMetrics(quantity, averagePrice, currentPrice);

  return {
    userId,
    startupId: normalizedStartupId,
    startupName,
    startupSymbol,
    quantity,
    reservedQuantity,
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

function serializeWalletHolding(
  holding: WalletHoldingRecord,
): SerializedWalletHolding {
  const availableQuantity = Math.max(
    0,
    holding.quantity - holding.reservedQuantity,
  );

  return {
    startupId: holding.startupId,
    startupName: holding.startupName,
    startupSymbol: holding.startupSymbol,
    quantity: holding.quantity,
    reservedQuantity: holding.reservedQuantity,
    availableQuantity,
    averagePrice: holding.averagePrice,
    currentPrice: holding.currentPrice,
    totalInvested: holding.totalInvested,
    currentValue: holding.currentValue,
    profitLoss: holding.profitLoss,
    profitLossPercent: holding.profitLossPercent,
    lastTransactionAt: serializeTimestamp(holding.lastTransactionAt),
    updatedAt: serializeTimestamp(holding.updatedAt),
  };
}

function normalizeWalletTransactionDocument(
  id: string,
  data: Partial<WalletTransactionDocument> | undefined,
): SerializedWalletTransaction {
  const totalValue = roundCurrency(
    Number(data?.totalValue ?? data?.totalAmount ?? 0),
  );

  return {
    id,
    userId: normalizeString(data?.userId),
    type: (data?.type ?? "DEPOSIT") as WalletTransactionType,
    startupId: data?.startupId ?? null,
    startupName: data?.startupName ?? null,
    startupSymbol: data?.startupSymbol ?? null,
    relatedUserId: data?.relatedUserId ?? null,
    offerId: data?.offerId ?? null,
    quantity: Math.trunc(Number(data?.quantity ?? 0)),
    unitPrice: roundCurrency(Number(data?.unitPrice ?? 0)),
    totalAmount: totalValue,
    totalValue,
    total: totalValue,
    amount: totalValue,
    balanceBefore: roundCurrency(Number(data?.balanceBefore ?? 0)),
    balanceAfter: roundCurrency(Number(data?.balanceAfter ?? 0)),
    tokensBefore: Math.trunc(Number(data?.tokensBefore ?? 0)),
    tokensAfter: Math.trunc(Number(data?.tokensAfter ?? 0)),
    status: normalizeString(data?.status),
    createdAt: serializeTimestamp(data?.createdAt),
    description: normalizeString(data?.description),
  };
}

function buildTransactionDocument(data: {
  balanceAfter: number;
  balanceBefore: number;
  description: string;
  offerId?: string | null;
  quantity: number;
  relatedUserId?: string | null;
  startupId: string | null;
  startupName: string | null;
  startupSymbol: string | null;
  status?: string;
  tokensAfter?: number;
  tokensBefore?: number;
  totalValue: number;
  type: WalletTransactionType;
  unitPrice: number;
  userId: string;
}): WalletTransactionDocument {
  const totalValue = roundCurrency(data.totalValue);

  return {
    userId: data.userId,
    type: data.type,
    startupId: data.startupId,
    startupName: data.startupName,
    startupSymbol: data.startupSymbol,
    relatedUserId: data.relatedUserId ?? null,
    offerId: data.offerId ?? null,
    quantity: Math.trunc(data.quantity),
    unitPrice: roundCurrency(data.unitPrice),
    totalAmount: totalValue,
    totalValue,
    balanceBefore: roundCurrency(data.balanceBefore),
    balanceAfter: roundCurrency(data.balanceAfter),
    tokensBefore: Math.trunc(data.tokensBefore ?? 0),
    tokensAfter: Math.trunc(data.tokensAfter ?? 0),
    status: data.status ?? "completed",
    createdAt: FieldValue.serverTimestamp(),
    description: data.description,
  };
}

function deriveStartupSymbol(
  startupId: string,
  startupName: string,
  providedSymbol?: string,
  startupData?: StartupRecord,
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

  return startupId.toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 6) ||
    "TOKN";
}

function getStartupName(
  startupId: string,
  providedName?: string,
  startupData?: StartupRecord,
): string {
  return normalizeString(providedName) ||
    normalizeString(startupData?.startupName) ||
    normalizeString(startupData?.name) ||
    normalizeString(startupData?.nome) ||
    normalizeString(startupData?.nomeStartup) ||
    startupId;
}

function getWalletRef(userId: string) {
  return db.collection(walletCollection).doc(userId);
}

function getLegacyWalletRef(userId: string) {
  return db.collection(legacyWalletCollection).doc(userId);
}

function getLegacyPluralWalletRef(userId: string) {
  return db.collection(legacyPluralWalletCollection).doc(userId);
}

function getWalletHoldingsRef(userId: string) {
  return getWalletRef(userId).collection(walletHoldingsCollection);
}

function getWalletHoldingRef(userId: string, startupId: string) {
  return getWalletHoldingsRef(userId).doc(startupId);
}

function getWalletTransactionsRef(userId: string) {
  return getWalletRef(userId).collection(walletTransactionsCollection);
}

function getMarketplaceOffersRef() {
  return db.collection(marketplaceOffersCollection);
}

function getMarketplaceOfferRef(offerId: string) {
  return getMarketplaceOffersRef().doc(offerId);
}

function getInvestorRef(startupId: string, userId: string) {
  return db
    .collection(startupsCollection)
    .doc(startupId)
    .collection("investors")
    .doc(userId);
}

function normalizeLegacyTokens(
  userId: string,
  tokens: unknown,
): WalletHoldingRecord[] {
  if (!Array.isArray(tokens)) {
    return [];
  }

  return tokens
    .map((token) => token as LegacyWalletToken)
    .filter((token) => normalizeString(token.startupId))
    .map((token) =>
      normalizeWalletHoldingDocument(
        normalizeString(token.startupId),
        userId,
        token as unknown as Partial<WalletHoldingDocument & LegacyWalletToken>,
      ),
    )
    .filter((token) => token.quantity > 0);
}

async function readLegacyWalletData(userId: string): Promise<LegacyWalletData> {
  const singularWalletRef = getLegacyWalletRef(userId);
  const pluralWalletRef = getLegacyPluralWalletRef(userId);

  const [
    singularWalletSnapshot,
    pluralWalletSnapshot,
    singularTokensSnapshot,
    pluralTokensSnapshot,
  ] = await Promise.all([
    singularWalletRef.get(),
    pluralWalletRef.get(),
    singularWalletRef.collection(walletLegacyTokensCollection).get(),
    pluralWalletRef.collection(walletLegacyTokensCollection).get(),
  ]);

  const singularData = singularWalletSnapshot.exists ?
    singularWalletSnapshot.data() as LegacyWalletDocument :
    undefined;
  const pluralData = pluralWalletSnapshot.exists ?
    pluralWalletSnapshot.data() as LegacyWalletDocument :
    undefined;
  const holdings = new Map<string, WalletHoldingRecord>();

  for (const token of normalizeLegacyTokens(userId, singularData?.tokens)) {
    holdings.set(token.startupId, token);
  }

  for (const token of normalizeLegacyTokens(userId, pluralData?.tokens)) {
    holdings.set(token.startupId, token);
  }

  singularTokensSnapshot.docs.forEach((document) => {
    const token = normalizeWalletHoldingDocument(
      document.id,
      userId,
      document.data() as Partial<WalletHoldingDocument & LegacyWalletToken>,
    );

    if (token.quantity > 0) {
      holdings.set(token.startupId, token);
    }
  });

  pluralTokensSnapshot.docs.forEach((document) => {
    const token = normalizeWalletHoldingDocument(
      document.id,
      userId,
      document.data() as Partial<WalletHoldingDocument & LegacyWalletToken>,
    );

    if (token.quantity > 0) {
      holdings.set(token.startupId, token);
    }
  });

  return {
    balance: roundCurrency(
      Number(singularData?.balance ?? pluralData?.balance ?? 0),
    ),
    createdAt: singularData?.createdAt ?? pluralData?.createdAt,
    updatedAt: singularData?.updatedAt ??
      singularData?.lastUpdated ??
      pluralData?.updatedAt ??
      pluralData?.lastUpdated,
    holdings: Array.from(holdings.values()),
  };
}

async function ensureWalletDocument(userId: string): Promise<void> {
  const walletRef = getWalletRef(userId);
  const walletSnapshot = await walletRef.get();

  if (walletSnapshot.exists) {
    return;
  }

  const legacyWalletData = await readLegacyWalletData(userId);
  const summary = calculateWalletSummary(legacyWalletData.holdings);

  await db.runTransaction(async (transaction) => {
    const currentWalletSnapshot = await transaction.get(walletRef);

    if (currentWalletSnapshot.exists) {
      return;
    }

    transaction.set(walletRef, {
      userId,
      balance: legacyWalletData.balance,
      totalInvested: summary.totalInvested,
      totalCurrentValue: summary.totalCurrentValue,
      totalProfitLoss: summary.totalProfitLoss,
      totalProfitLossPercent: summary.totalProfitLossPercent,
      createdAt: coerceTimestampForWrite(legacyWalletData.createdAt),
      updatedAt: coerceTimestampForWrite(legacyWalletData.updatedAt),
    } satisfies WalletDocument);

    for (const holding of legacyWalletData.holdings) {
      transaction.set(
        getWalletHoldingRef(userId, holding.startupId),
        {
          ...buildHoldingDocument({
            userId,
            startupId: holding.startupId,
            startupName: holding.startupName,
            startupSymbol: holding.startupSymbol,
            quantity: holding.quantity,
            reservedQuantity: holding.reservedQuantity,
            averagePrice: holding.averagePrice,
            currentPrice: holding.currentPrice,
          }),
          lastTransactionAt: coerceTimestampForWrite(holding.lastTransactionAt),
          updatedAt: coerceTimestampForWrite(holding.updatedAt),
        } satisfies WalletHoldingDocument,
      );
    }
  });
}

async function syncWalletSummary(userId: string): Promise<void> {
  const walletRef = getWalletRef(userId);
  const [walletSnapshot, holdingsSnapshot] = await Promise.all([
    walletRef.get(),
    getWalletHoldingsRef(userId).get(),
  ]);

  if (!walletSnapshot.exists) {
    throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
  }

  const normalizedHoldings = holdingsSnapshot.docs.map((document) =>
    normalizeWalletHoldingDocument(
      document.id,
      userId,
      document.data() as Partial<WalletHoldingDocument>,
    ),
  );
  const normalizedWithOfficialPrices = await Promise.all(
    normalizedHoldings.map(async (holding) => {
      try {
        const startupData = await getStartupDataOrThrow(holding.startupId);
        const officialUnitPrice = resolveOfficialStartupUnitPrice(startupData);
        const refreshed = buildHoldingDocument({
          userId,
          startupId: holding.startupId,
          startupName: holding.startupName,
          startupSymbol: holding.startupSymbol,
          quantity: holding.quantity,
          reservedQuantity: holding.reservedQuantity,
          averagePrice: holding.averagePrice,
          currentPrice: officialUnitPrice,
        });

        await getWalletHoldingRef(userId, holding.startupId)
          .set(refreshed, {merge: true});

        return normalizeWalletHoldingDocument(
          holding.startupId,
          userId,
          refreshed,
        );
      } catch {
        return holding;
      }
    }),
  );
  const summary = calculateWalletSummary(normalizedWithOfficialPrices);

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
  const [walletSnapshot, holdingsSnapshot, transactionsSnapshot] =
    await Promise.all([
      walletRef.get(),
      getWalletHoldingsRef(userId).orderBy("updatedAt", "desc").get(),
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
  const normalizedHoldings = holdingsSnapshot.docs.map((document) =>
    normalizeWalletHoldingDocument(
      document.id,
      userId,
      document.data() as Partial<WalletHoldingDocument>,
    ),
  );
  const summary = calculateWalletSummary(normalizedHoldings);
  const holdings = normalizedHoldings.map(serializeWalletHolding);
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
    holdings,
    tokens: holdings,
    recentTransactions,
  };

  return {
    wallet,
    holdings,
    tokens: holdings,
    recentTransactions,
  };
}

function getNumericStartupField(
  startupData: StartupRecord,
  keys: string[],
): number {
  for (const key of keys) {
    const raw = startupData[key];
    const parsed = parseNumber(
      typeof raw === "number" || typeof raw === "string" ? raw : undefined,
    );

    if (Number.isFinite(parsed) && parsed > 0) {
      return parsed;
    }
  }

  return 0;
}

function resolveStartupUnitPrice(
  startupData: StartupRecord,
  providedPrice?: number | string,
): number {
  const directPrice = getNumericStartupField(startupData, [
    "tokenPrice",
    "unitPrice",
    "valorToken",
    "pricePerToken",
  ]);

  if (directPrice > 0) {
    return roundCurrency(directPrice);
  }

  const targetCapital = getNumericStartupField(startupData, [
    "targetCapital",
    "metaCaptacao",
  ]);
  const emittedTokens = getNumericStartupField(startupData, [
    "totalEmittedTokens",
    "tokensEmitidos",
    "tokens",
  ]);

  if (targetCapital > 0 && emittedTokens > 0) {
    return roundCurrency(targetCapital / emittedTokens);
  }

  const parsedProvidedPrice = parseNumber(providedPrice);

  if (Number.isFinite(parsedProvidedPrice) && parsedProvidedPrice > 0) {
    return roundCurrency(parsedProvidedPrice);
  }

  return 1;
}

function resolveOfficialStartupUnitPrice(startupData: StartupRecord): number {
  return resolveStartupUnitPrice(startupData);
}

function resolvePrimaryAvailableQuantity(
  startupData: StartupRecord,
  unitPrice: number,
): number | null {
  const explicitAvailable = getNumericStartupField(startupData, [
    "availableTokens",
    "tokensAvailable",
    "tokensDisponiveis",
  ]);

  if (explicitAvailable > 0) {
    return Math.trunc(explicitAvailable);
  }

  const totalTokens = getNumericStartupField(startupData, [
    "totalEmittedTokens",
    "tokensEmitidos",
    "tokens",
  ]);

  if (totalTokens <= 0) {
    return null;
  }

  const soldTokens = getNumericStartupField(startupData, [
    "soldTokens",
    "tokensSold",
    "tokensVendidos",
  ]);

  if (soldTokens > 0) {
    return Math.max(0, Math.trunc(totalTokens - soldTokens));
  }

  const raisedCapital = getNumericStartupField(startupData, [
    "raisedCapital",
    "capitalAportado",
  ]);

  if (raisedCapital > 0 && unitPrice > 0) {
    return Math.max(0, Math.trunc(totalTokens - (raisedCapital / unitPrice)));
  }

  return Math.trunc(totalTokens);
}

async function resolveUserName(userId: string): Promise<string> {
  const userSnapshot = await db.collection(usersCollection).doc(userId).get();

  if (userSnapshot.exists) {
    const userData = userSnapshot.data() ?? {};
    const name = normalizeString(userData.displayName) ||
      normalizeString(userData.name) ||
      normalizeString(userData.nome) ||
      normalizeString(userData.email);

    if (name) {
      return name.includes("@") ? name.split("@")[0] : name;
    }
  }

  return "Investidor";
}

function normalizeOfferDocument(
  id: string,
  data: Partial<MarketplaceOfferDocument>,
): SerializedMarketplaceOffer {
  const unitPrice = roundCurrency(
    Number(data.unitPrice ?? data.pricePerToken ?? data.price ?? 0),
  );
  const quantity = Math.trunc(Number(data.quantity ?? 0));
  const remainingQuantity = Math.trunc(
    Number(data.remainingQuantity ?? quantity),
  );
  const status = (data.status ?? "open") as MarketplaceOfferStatus;
  const sellerId = normalizeString(data.sellerId);
  const startupName = normalizeString(data.startupName) || "Startup";

  return {
    id,
    ownerId: sellerId,
    sellerId,
    sellerName: normalizeString(data.sellerName) || "Investidor",
    startupId: normalizeString(data.startupId),
    startupName,
    startupStage: data.startupStage ?? null,
    title: startupName,
    type: "sell",
    quantity,
    amount: quantity,
    remainingQuantity,
    unitPrice,
    pricePerToken: unitPrice,
    price: unitPrice,
    totalValue: roundCurrency(Number(data.totalValue ?? quantity * unitPrice)),
    status,
    createdAt: serializeTimestamp(data.createdAt),
    updatedAt: serializeTimestamp(data.updatedAt),
  };
}

function buildOfferDocument(data: {
  offerId: string;
  quantity: number;
  sellerId: string;
  sellerName: string;
  startupData: StartupRecord;
  startupId: string;
  startupName: string;
  unitPrice: number;
}): MarketplaceOfferDocument {
  const startupStage = normalizeStage(
    data.startupData.stage ?? data.startupData.estagio,
  ) || null;
  const totalValue = roundCurrency(data.quantity * data.unitPrice);

  return {
    id: data.offerId,
    sellerId: data.sellerId,
    sellerName: data.sellerName,
    startupId: data.startupId,
    startupName: data.startupName,
    startupStage,
    type: "sell",
    quantity: data.quantity,
    remainingQuantity: data.quantity,
    unitPrice: data.unitPrice,
    pricePerToken: data.unitPrice,
    price: data.unitPrice,
    totalValue,
    status: "open",
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

async function findStartupByField(
  field: string,
  startupId: string,
): Promise<{data: StartupRecord; id: string} | null> {
  const snapshot = await db
    .collection(startupsCollection)
    .where(field, "==", startupId)
    .limit(1)
    .get();

  if (snapshot.empty) {
    return null;
  }

  const document = snapshot.docs[0];

  return {
    id: document.id,
    data: document.data() as StartupRecord,
  };
}

function buildEmulatorStartupData(
  startupId: string,
  fallback?: StartupLookupFallback,
): StartupRecord | null {
  if (process.env.FUNCTIONS_EMULATOR !== "true") {
    return null;
  }

  const startupName = normalizeString(fallback?.startupName) || startupId;
  const unitPrice = parseNumber(fallback?.unitPrice);
  const tokenPrice = Number.isFinite(unitPrice) && unitPrice > 0 ?
    roundCurrency(unitPrice) :
    1;

  return {
    id: startupId,
    name: startupName,
    startupName,
    startupSymbol: normalizeString(fallback?.startupSymbol) ||
      deriveStartupSymbol(startupId, startupName),
    tokenPrice,
    unitPrice: tokenPrice,
    type: "emulatorFallback",
  };
}

async function getStartupDataOrThrow(
  startupId: string,
  fallback?: StartupLookupFallback,
): Promise<StartupRecord> {
  const startupSnapshot = await db
    .collection(startupsCollection)
    .doc(startupId)
    .get();

  if (startupSnapshot.exists) {
    return {
      ...(startupSnapshot.data() as StartupRecord),
      id: startupSnapshot.id,
    };
  }

  for (const field of ["id", "startupId", "docId"]) {
    const match = await findStartupByField(field, startupId);

    if (match) {
      return {
        ...match.data,
        id: match.id,
      };
    }
  }

  const emulatorStartupData = buildEmulatorStartupData(startupId, fallback);

  if (emulatorStartupData) {
    await db
      .collection(startupsCollection)
      .doc(startupId)
      .set({
        ...emulatorStartupData,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});

    return emulatorStartupData;
  }

  throw createServiceError(404, "Startup invalida.");
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
  const amount = parsePositiveCurrency(data.amount, "amount");
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
      userId,
      type: "DEPOSIT",
      startupId: null,
      startupName: null,
      startupSymbol: null,
      quantity: 0,
      unitPrice: 0,
      totalValue: amount,
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
  const amount = parsePositiveCurrency(data.amount, "amount");
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
      userId,
      type: "WITHDRAW",
      startupId: null,
      startupName: null,
      startupSymbol: null,
      quantity: 0,
      unitPrice: 0,
      totalValue: amount,
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
  const quantity = parsePositiveQuantity(data.quantity, "quantity");
  const historyLimit = parseHistoryLimit(data.historyLimit);

  if (!startupId) {
    throw createServiceError(400, "startupId e obrigatorio.");
  }

  await ensureWalletDocument(userId);

  const startupData = await getStartupDataOrThrow(startupId, {
    startupName: data.startupName,
    startupSymbol: data.startupSymbol,
    unitPrice: data.unitPrice ?? data.price,
  });
  const canonicalStartupId = normalizeString(startupData.id) || startupId;
  const startupName = getStartupName(
    canonicalStartupId,
    data.startupName,
    startupData,
  );
  const startupSymbol = deriveStartupSymbol(
    canonicalStartupId,
    startupName,
    data.startupSymbol,
    startupData,
  );
  const unitPrice = resolveStartupUnitPrice(
    startupData,
    data.unitPrice ?? data.price,
  );
  const availableQuantity = resolvePrimaryAvailableQuantity(
    startupData,
    unitPrice,
  );

  if (availableQuantity !== null && quantity > availableQuantity) {
    throw createServiceError(400, "Quantidade maior que os tokens disponiveis.");
  }

  const walletRef = getWalletRef(userId);
  const holdingRef = getWalletHoldingRef(userId, canonicalStartupId);
  const startupRef = db.collection(startupsCollection).doc(canonicalStartupId);
  const transactionRef = getWalletTransactionsRef(userId).doc();
  const investorRef = getInvestorRef(canonicalStartupId, userId);

  await db.runTransaction(async (transaction) => {
    const [walletSnapshot, holdingSnapshot] = await Promise.all([
      transaction.get(walletRef),
      transaction.get(holdingRef),
    ]);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    const wallet = normalizeWalletDocument(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const totalValue = roundCurrency(quantity * unitPrice);

    if (wallet.balance < totalValue) {
      throw createServiceError(400, "Saldo insuficiente");
    }

    const existingHolding = holdingSnapshot.exists ?
      normalizeWalletHoldingDocument(
        canonicalStartupId,
        userId,
        holdingSnapshot.data() as Partial<WalletHoldingDocument>,
      ) :
      null;
    const tokensBefore = existingHolding?.quantity ?? 0;
    const existingAveragePrice = existingHolding?.averagePrice ?? 0;
    const updatedQuantity = tokensBefore + quantity;
    const updatedAveragePrice = updatedQuantity > 0 ?
      roundCurrency(
        ((tokensBefore * existingAveragePrice) + (quantity * unitPrice)) /
          updatedQuantity,
      ) :
      0;
    const balanceBefore = wallet.balance;
    const balanceAfter = roundCurrency(balanceBefore - totalValue);

    transaction.set(walletRef, {
      balance: balanceAfter,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(holdingRef, buildHoldingDocument({
      userId,
      startupId: canonicalStartupId,
      startupName,
      startupSymbol,
      quantity: updatedQuantity,
      reservedQuantity: existingHolding?.reservedQuantity ?? 0,
      averagePrice: updatedAveragePrice,
      currentPrice: unitPrice,
    }));
    transaction.set(startupRef, {
      raisedCapital: FieldValue.increment(totalValue),
      soldTokens: FieldValue.increment(quantity),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(investorRef, {
      userId,
      startupId: canonicalStartupId,
      startupName,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(transactionRef, buildTransactionDocument({
      userId,
      type: "BUY",
      startupId: canonicalStartupId,
      startupName,
      startupSymbol,
      quantity,
      unitPrice,
      totalValue,
      balanceBefore,
      balanceAfter,
      tokensBefore,
      tokensAfter: updatedQuantity,
      description: `Compra de tokens da startup ${startupName}`,
    }));
  });

  await syncWalletSummary(userId);
  return buildWalletOverview(userId, historyLimit);
};

export const createSellOffer = async (data: SellOfferInput) => {
  const userId = resolveAuthorizedUserId(data);
  const startupId = normalizeString(data.startupId);
  const quantity = parsePositiveQuantity(data.quantity, "quantity");
  const unitPrice = parsePositiveCurrency(
    data.unitPrice ?? data.price,
    "unitPrice",
  );
  const historyLimit = parseHistoryLimit(data.historyLimit);

  if (!startupId) {
    throw createServiceError(400, "startupId e obrigatorio.");
  }

  await ensureWalletDocument(userId);

  const startupData = await getStartupDataOrThrow(startupId, {
    startupName: data.startupName,
    startupSymbol: data.startupSymbol,
    unitPrice: data.unitPrice ?? data.price,
  });
  const canonicalStartupId = normalizeString(startupData.id) || startupId;
  const startupName = getStartupName(
    canonicalStartupId,
    data.startupName,
    startupData,
  );
  const startupSymbol = deriveStartupSymbol(
    canonicalStartupId,
    startupName,
    data.startupSymbol,
    startupData,
  );
  const officialUnitPrice = resolveOfficialStartupUnitPrice(startupData);
  const sellerName = await resolveUserName(userId);
  const walletRef = getWalletRef(userId);
  const holdingRef = getWalletHoldingRef(userId, canonicalStartupId);
  const offerRef = getMarketplaceOffersRef().doc();
  const transactionRef = getWalletTransactionsRef(userId).doc();

  await db.runTransaction(async (transaction) => {
    const [walletSnapshot, holdingSnapshot] = await Promise.all([
      transaction.get(walletRef),
      transaction.get(holdingRef),
    ]);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    if (!holdingSnapshot.exists) {
      throw createServiceError(400, "Quantidade de tokens insuficiente");
    }

    const wallet = normalizeWalletDocument(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const holding = normalizeWalletHoldingDocument(
      canonicalStartupId,
      userId,
      holdingSnapshot.data() as Partial<WalletHoldingDocument>,
    );
    const availableQuantity = holding.quantity - holding.reservedQuantity;

    if (availableQuantity < quantity) {
      throw createServiceError(400, "Quantidade de tokens insuficiente");
    }

    const reservedQuantity = holding.reservedQuantity + quantity;
    const totalValue = roundCurrency(quantity * unitPrice);

    transaction.set(holdingRef, buildHoldingDocument({
      userId,
      startupId: holding.startupId,
      startupName: holding.startupName || startupName,
      startupSymbol: holding.startupSymbol || startupSymbol,
      quantity: holding.quantity,
      reservedQuantity,
      averagePrice: holding.averagePrice,
      currentPrice: officialUnitPrice,
    }));
    transaction.set(offerRef, buildOfferDocument({
      offerId: offerRef.id,
      sellerId: userId,
      sellerName,
      startupId: canonicalStartupId,
      startupName,
      startupData,
      quantity,
      unitPrice,
    }));
    transaction.set(transactionRef, buildTransactionDocument({
      userId,
      type: "SELL_OFFER_CREATED",
      startupId: canonicalStartupId,
      startupName,
      startupSymbol,
      quantity,
      unitPrice,
      totalValue,
      balanceBefore: wallet.balance,
      balanceAfter: wallet.balance,
      tokensBefore: holding.quantity,
      tokensAfter: holding.quantity,
      offerId: offerRef.id,
      status: "open",
      description: `Oferta publica de venda criada para ${startupName}`,
    }));
  });

  await syncWalletSummary(userId);

  const overview = await buildWalletOverview(userId, historyLimit);

  return {
    ...overview,
    offer: normalizeOfferDocument(offerRef.id, {
      ...buildOfferDocument({
        offerId: offerRef.id,
        sellerId: userId,
        sellerName,
        startupId: canonicalStartupId,
        startupName,
        startupData,
        quantity,
        unitPrice,
      }),
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    }),
  };
};

export const listMarketplaceOffers = async (
  data: MarketplaceOffersInput = {},
) => {
  const startupId = normalizeString(data.startupId);
  const stage = normalizeStage(data.stage);
  const snapshot = await getMarketplaceOffersRef()
    .where("type", "==", "sell")
    .get();
  const offers = snapshot.docs
    .map((document) =>
      normalizeOfferDocument(
        document.id,
        document.data() as Partial<MarketplaceOfferDocument>,
      ),
    )
    .filter((offer) => {
      const visibleStatus = offer.status === "open" ||
        offer.status === "partial";
      const hasRemaining = offer.remainingQuantity > 0;
      const matchesStartup = !startupId || offer.startupId === startupId;
      const matchesStage = !stage ||
        normalizeStage(offer.startupStage) === stage;

      return visibleStatus && hasRemaining && matchesStartup && matchesStage;
    });

  offers.sort((left, right) => {
    const leftDate = Date.parse(left.createdAt ?? "");
    const rightDate = Date.parse(right.createdAt ?? "");

    if (Number.isNaN(leftDate) && Number.isNaN(rightDate)) {
      return 0;
    }

    if (Number.isNaN(leftDate)) {
      return 1;
    }

    if (Number.isNaN(rightDate)) {
      return -1;
    }

    return rightDate - leftDate;
  });

  return offers;
};

export const buyMarketplaceOffer = async (data: BuyMarketplaceOfferInput) => {
  const buyerId = resolveAuthorizedUserId(data);
  const offerId = normalizeString(data.offerId);
  const quantity = parsePositiveQuantity(data.quantity, "quantity");
  const historyLimit = parseHistoryLimit(data.historyLimit);

  if (!offerId) {
    throw createServiceError(400, "offerId e obrigatorio.");
  }

  await ensureWalletDocument(buyerId);

  const offerRef = getMarketplaceOfferRef(offerId);
  const buyerWalletRef = getWalletRef(buyerId);
  const buyerTransactionRef = getWalletTransactionsRef(buyerId).doc();
  let sellerIdForSummary = "";
  let officialUnitPrice = 0;

  await db.runTransaction(async (transaction) => {
    const offerSnapshot = await transaction.get(offerRef);

    if (!offerSnapshot.exists) {
      throw createServiceError(404, "Oferta nao encontrada.");
    }

    const offer = normalizeOfferDocument(
      offerSnapshot.id,
      offerSnapshot.data() as Partial<MarketplaceOfferDocument>,
    );

    if (offer.status !== "open" && offer.status !== "partial") {
      throw createServiceError(400, "Oferta indisponivel.");
    }

    if (offer.sellerId === buyerId) {
      throw createServiceError(400, "Nao e possivel comprar a propria oferta.");
    }

    if (quantity > offer.remainingQuantity) {
      throw createServiceError(400, "Quantidade maior que a oferta disponivel.");
    }

    const startupData = await getStartupDataOrThrow(offer.startupId);
    officialUnitPrice = resolveOfficialStartupUnitPrice(startupData);
    const sellerId = offer.sellerId;
    sellerIdForSummary = sellerId;
    const sellerWalletRef = getWalletRef(sellerId);
    const buyerHoldingRef = getWalletHoldingRef(buyerId, offer.startupId);
    const sellerHoldingRef = getWalletHoldingRef(sellerId, offer.startupId);
    const sellerTransactionRef = getWalletTransactionsRef(sellerId).doc();
    const buyerInvestorRef = getInvestorRef(offer.startupId, buyerId);
    const sellerInvestorRef = getInvestorRef(offer.startupId, sellerId);

    const [
      buyerWalletSnapshot,
      sellerWalletSnapshot,
      buyerHoldingSnapshot,
      sellerHoldingSnapshot,
    ] = await Promise.all([
      transaction.get(buyerWalletRef),
      transaction.get(sellerWalletRef),
      transaction.get(buyerHoldingRef),
      transaction.get(sellerHoldingRef),
    ]);

    if (!buyerWalletSnapshot.exists) {
      throw createServiceError(404, "Carteira do comprador nao encontrada.");
    }

    if (!sellerWalletSnapshot.exists) {
      throw createServiceError(404, "Carteira do vendedor nao encontrada.");
    }

    if (!sellerHoldingSnapshot.exists) {
      throw createServiceError(400, "Tokens reservados do vendedor nao encontrados.");
    }

    const buyerWallet = normalizeWalletDocument(
      buyerId,
      buyerWalletSnapshot.data() as Partial<WalletDocument>,
    );
    const sellerWallet = normalizeWalletDocument(
      sellerId,
      sellerWalletSnapshot.data() as Partial<WalletDocument>,
    );
    const sellerHolding = normalizeWalletHoldingDocument(
      offer.startupId,
      sellerId,
      sellerHoldingSnapshot.data() as Partial<WalletHoldingDocument>,
    );

    if (sellerHolding.quantity < quantity ||
        sellerHolding.reservedQuantity < quantity) {
      throw createServiceError(400, "Oferta sem tokens reservados suficientes.");
    }

    const totalValue = roundCurrency(quantity * offer.unitPrice);

    if (buyerWallet.balance < totalValue) {
      throw createServiceError(400, "Saldo insuficiente");
    }

    const buyerExistingHolding = buyerHoldingSnapshot.exists ?
      normalizeWalletHoldingDocument(
        offer.startupId,
        buyerId,
        buyerHoldingSnapshot.data() as Partial<WalletHoldingDocument>,
      ) :
      null;
    const buyerTokensBefore = buyerExistingHolding?.quantity ?? 0;
    const buyerReservedQuantity = buyerExistingHolding?.reservedQuantity ?? 0;
    const buyerAveragePrice = buyerExistingHolding?.averagePrice ?? 0;
    const buyerTokensAfter = buyerTokensBefore + quantity;
    const buyerUpdatedAveragePrice = buyerTokensAfter > 0 ?
      roundCurrency(
        ((buyerTokensBefore * buyerAveragePrice) +
          (quantity * offer.unitPrice)) /
          buyerTokensAfter,
      ) :
      0;
    const sellerTokensBefore = sellerHolding.quantity;
    const sellerTokensAfter = sellerTokensBefore - quantity;
    const sellerReservedAfter = sellerHolding.reservedQuantity - quantity;
    const remainingQuantity = offer.remainingQuantity - quantity;
    const offerStatus: MarketplaceOfferStatus =
      remainingQuantity === 0 ? "closed" : "partial";

    transaction.set(buyerWalletRef, {
      balance: roundCurrency(buyerWallet.balance - totalValue),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(sellerWalletRef, {
      balance: roundCurrency(sellerWallet.balance + totalValue),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(buyerHoldingRef, buildHoldingDocument({
      userId: buyerId,
      startupId: offer.startupId,
      startupName: offer.startupName,
      startupSymbol: deriveStartupSymbol(offer.startupId, offer.startupName),
      quantity: buyerTokensAfter,
      reservedQuantity: buyerReservedQuantity,
      averagePrice: buyerUpdatedAveragePrice,
      currentPrice: officialUnitPrice,
    }));

    if (sellerTokensAfter <= 0) {
      transaction.delete(sellerHoldingRef);
      transaction.delete(sellerInvestorRef);
    } else {
      transaction.set(sellerHoldingRef, buildHoldingDocument({
        userId: sellerId,
        startupId: offer.startupId,
        startupName: offer.startupName,
        startupSymbol: sellerHolding.startupSymbol ||
          deriveStartupSymbol(offer.startupId, offer.startupName),
        quantity: sellerTokensAfter,
        reservedQuantity: sellerReservedAfter,
        averagePrice: sellerHolding.averagePrice,
        currentPrice: officialUnitPrice,
      }));
    }

    transaction.set(buyerInvestorRef, {
      userId: buyerId,
      startupId: offer.startupId,
      startupName: offer.startupName,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(offerRef, {
      remainingQuantity,
      status: offerStatus,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(buyerTransactionRef, buildTransactionDocument({
      userId: buyerId,
      type: "BUY_MARKETPLACE",
      startupId: offer.startupId,
      startupName: offer.startupName,
      startupSymbol: deriveStartupSymbol(offer.startupId, offer.startupName),
      relatedUserId: sellerId,
      offerId,
      quantity,
      unitPrice: offer.unitPrice,
      totalValue,
      balanceBefore: buyerWallet.balance,
      balanceAfter: roundCurrency(buyerWallet.balance - totalValue),
      tokensBefore: buyerTokensBefore,
      tokensAfter: buyerTokensAfter,
      status: offerStatus,
      description: `Compra de oferta publica de ${offer.startupName}`,
    }));
    transaction.set(sellerTransactionRef, buildTransactionDocument({
      userId: sellerId,
      type: "SELL_MARKETPLACE",
      startupId: offer.startupId,
      startupName: offer.startupName,
      startupSymbol: sellerHolding.startupSymbol ||
        deriveStartupSymbol(offer.startupId, offer.startupName),
      relatedUserId: buyerId,
      offerId,
      quantity,
      unitPrice: offer.unitPrice,
      totalValue,
      balanceBefore: sellerWallet.balance,
      balanceAfter: roundCurrency(sellerWallet.balance + totalValue),
      tokensBefore: sellerTokensBefore,
      tokensAfter: sellerTokensAfter,
      status: offerStatus,
      description: `Venda executada no marketplace de ${offer.startupName}`,
    }));
  });

  await Promise.all([
    syncWalletSummary(buyerId),
    sellerIdForSummary ? syncWalletSummary(sellerIdForSummary) : Promise.resolve(),
  ]);

  return buildWalletOverview(buyerId, historyLimit);
};

export const cancelMarketplaceOffer = async (data: WalletAccessInput & {
  offerId?: string;
}) => {
  const userId = resolveAuthorizedUserId(data);
  const offerId = normalizeString(data.offerId);
  const historyLimit = parseHistoryLimit(data.historyLimit);

  if (!offerId) {
    throw createServiceError(400, "offerId e obrigatorio.");
  }

  const offerRef = getMarketplaceOfferRef(offerId);
  const walletRef = getWalletRef(userId);
  const transactionRef = getWalletTransactionsRef(userId).doc();

  await db.runTransaction(async (transaction) => {
    const offerSnapshot = await transaction.get(offerRef);

    if (!offerSnapshot.exists) {
      throw createServiceError(404, "Oferta nao encontrada.");
    }

    const offer = normalizeOfferDocument(
      offerSnapshot.id,
      offerSnapshot.data() as Partial<MarketplaceOfferDocument>,
    );

    if (offer.sellerId !== userId) {
      throw createServiceError(403, "Apenas o dono pode cancelar esta oferta.");
    }

    if (offer.status !== "open" && offer.status !== "partial") {
      throw createServiceError(400, "Oferta nao pode mais ser cancelada.");
    }

    const [walletSnapshot, holdingSnapshot, startupData] = await Promise.all([
      transaction.get(walletRef),
      transaction.get(getWalletHoldingRef(userId, offer.startupId)),
      getStartupDataOrThrow(offer.startupId),
    ]);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    if (!holdingSnapshot.exists) {
      throw createServiceError(400, "Tokens reservados nao encontrados.");
    }

    const wallet = normalizeWalletDocument(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const holding = normalizeWalletHoldingDocument(
      offer.startupId,
      userId,
      holdingSnapshot.data() as Partial<WalletHoldingDocument>,
    );
    const releasedQuantity = Math.min(
      holding.reservedQuantity,
      offer.remainingQuantity,
    );

    transaction.set(getWalletHoldingRef(userId, offer.startupId), buildHoldingDocument({
      userId,
      startupId: holding.startupId,
      startupName: holding.startupName || offer.startupName,
      startupSymbol: holding.startupSymbol ||
        deriveStartupSymbol(offer.startupId, offer.startupName),
      quantity: holding.quantity,
      reservedQuantity: holding.reservedQuantity - releasedQuantity,
      averagePrice: holding.averagePrice,
      currentPrice: resolveOfficialStartupUnitPrice(startupData),
    }));
    transaction.set(offerRef, {
      status: "cancelled",
      remainingQuantity: 0,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(transactionRef, buildTransactionDocument({
      userId,
      type: "OFFER_CANCELLED",
      startupId: offer.startupId,
      startupName: offer.startupName,
      startupSymbol: holding.startupSymbol ||
        deriveStartupSymbol(offer.startupId, offer.startupName),
      quantity: releasedQuantity,
      unitPrice: offer.unitPrice,
      totalValue: roundCurrency(releasedQuantity * offer.unitPrice),
      balanceBefore: wallet.balance,
      balanceAfter: wallet.balance,
      tokensBefore: holding.quantity,
      tokensAfter: holding.quantity,
      offerId,
      status: "cancelled",
      description: `Oferta publica de venda cancelada para ${offer.startupName}`,
    }));
  });

  await syncWalletSummary(userId);
  return buildWalletOverview(userId, historyLimit);
};

export const updateMarketplaceOffer = async (
  data: UpdateMarketplaceOfferInput,
) => {
  const userId = resolveAuthorizedUserId(data);
  const offerId = normalizeString(data.offerId);
  const nextUnitPriceRaw = data.unitPrice ?? data.price;
  const hasNextPrice = nextUnitPriceRaw !== undefined;
  const hasNextQuantity = data.quantity !== undefined;
  const nextUnitPrice = hasNextPrice ?
    parsePositiveCurrency(nextUnitPriceRaw, "unitPrice") :
    null;
  const nextQuantity = hasNextQuantity ?
    parsePositiveQuantity(data.quantity, "quantity") :
    null;
  const historyLimit = parseHistoryLimit(data.historyLimit);

  if (!offerId) {
    throw createServiceError(400, "offerId e obrigatorio.");
  }

  if (!hasNextPrice && !hasNextQuantity) {
    throw createServiceError(400, "Informe preco ou quantidade para alterar.");
  }

  const offerRef = getMarketplaceOfferRef(offerId);
  const walletRef = getWalletRef(userId);
  const transactionRef = getWalletTransactionsRef(userId).doc();

  await db.runTransaction(async (transaction) => {
    const offerSnapshot = await transaction.get(offerRef);

    if (!offerSnapshot.exists) {
      throw createServiceError(404, "Oferta nao encontrada.");
    }

    const offer = normalizeOfferDocument(
      offerSnapshot.id,
      offerSnapshot.data() as Partial<MarketplaceOfferDocument>,
    );

    if (offer.sellerId !== userId) {
      throw createServiceError(403, "Apenas o dono pode alterar esta oferta.");
    }

    if (offer.status !== "open" && offer.status !== "partial") {
      throw createServiceError(400, "Oferta nao pode mais ser alterada.");
    }

    const [walletSnapshot, holdingSnapshot, startupData] = await Promise.all([
      transaction.get(walletRef),
      transaction.get(getWalletHoldingRef(userId, offer.startupId)),
      getStartupDataOrThrow(offer.startupId),
    ]);

    if (!walletSnapshot.exists) {
      throw createServiceError(404, "Carteira nao encontrada para o usuario informado.");
    }

    if (!holdingSnapshot.exists) {
      throw createServiceError(400, "Tokens reservados nao encontrados.");
    }

    const wallet = normalizeWalletDocument(
      userId,
      walletSnapshot.data() as Partial<WalletDocument>,
    );
    const holding = normalizeWalletHoldingDocument(
      offer.startupId,
      userId,
      holdingSnapshot.data() as Partial<WalletHoldingDocument>,
    );
    const soldQuantity = offer.quantity - offer.remainingQuantity;
    const updatedQuantity = nextQuantity ?? offer.quantity;

    if (updatedQuantity < soldQuantity) {
      throw createServiceError(400, "Quantidade menor que os tokens ja vendidos.");
    }

    const reservedDelta = updatedQuantity - offer.quantity;
    const newReservedQuantity = holding.reservedQuantity + reservedDelta;

    if (newReservedQuantity < 0 || newReservedQuantity > holding.quantity) {
      throw createServiceError(400, "Quantidade de tokens insuficiente.");
    }

    const updatedUnitPrice = nextUnitPrice ?? offer.unitPrice;
    const updatedRemainingQuantity = updatedQuantity - soldQuantity;
    const updatedStatus: MarketplaceOfferStatus =
      updatedRemainingQuantity === 0 ? "closed" :
        soldQuantity > 0 ? "partial" : "open";

    transaction.set(getWalletHoldingRef(userId, offer.startupId), buildHoldingDocument({
      userId,
      startupId: holding.startupId,
      startupName: holding.startupName || offer.startupName,
      startupSymbol: holding.startupSymbol ||
        deriveStartupSymbol(offer.startupId, offer.startupName),
      quantity: holding.quantity,
      reservedQuantity: newReservedQuantity,
      averagePrice: holding.averagePrice,
      currentPrice: resolveOfficialStartupUnitPrice(startupData),
    }));
    transaction.set(offerRef, {
      quantity: updatedQuantity,
      remainingQuantity: updatedRemainingQuantity,
      unitPrice: updatedUnitPrice,
      pricePerToken: updatedUnitPrice,
      price: updatedUnitPrice,
      totalValue: roundCurrency(updatedQuantity * updatedUnitPrice),
      status: updatedStatus,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    transaction.set(transactionRef, buildTransactionDocument({
      userId,
      type: "OFFER_UPDATED",
      startupId: offer.startupId,
      startupName: offer.startupName,
      startupSymbol: holding.startupSymbol ||
        deriveStartupSymbol(offer.startupId, offer.startupName),
      quantity: updatedQuantity,
      unitPrice: updatedUnitPrice,
      totalValue: roundCurrency(updatedQuantity * updatedUnitPrice),
      balanceBefore: wallet.balance,
      balanceAfter: wallet.balance,
      tokensBefore: holding.quantity,
      tokensAfter: holding.quantity,
      offerId,
      status: updatedStatus,
      description: `Oferta publica de venda alterada para ${offer.startupName}`,
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

export const getTokenMetrics = async (
  userId: string,
  startupId: string,
) => {
  await ensureWalletDocument(userId);

  const [holdingSnapshot, startupData] = await Promise.all([
    getWalletHoldingRef(userId, startupId).get(),
    getStartupDataOrThrow(startupId),
  ]);

  if (!holdingSnapshot.exists) {
    throw createServiceError(404, "Token nao encontrado.");
  }

  const holding = normalizeWalletHoldingDocument(
    startupId,
    userId,
    holdingSnapshot.data() as Partial<WalletHoldingDocument>,
  );
  const currentPrice = resolveStartupUnitPrice(startupData, holding.currentPrice);
  const investedValue = holding.averagePrice * holding.quantity;
  const currentValue = currentPrice * holding.quantity;
  const profit = roundCurrency(currentValue - investedValue);
  const valuation = investedValue > 0 ?
    roundPercent((profit / investedValue) * 100) :
    0;

  return {
    amount: holding.quantity,
    averagePrice: holding.averagePrice,
    currentPrice,
    profit,
    valuation,
  };
};

export const getUserInvestmentsMetrics = async (userId: string) => {
  const overview = await getWalletByUserId({
    authenticatedUserId: userId,
    userId,
  });
  const investments = overview.holdings.map((holding) => ({
    startupId: holding.startupId,
    amount: holding.quantity,
    currentPrice: holding.currentPrice,
    averagePrice: holding.averagePrice,
    valuation: holding.profitLossPercent,
    profit: holding.profitLoss,
  }));

  return {
    investments,
    investedValue: overview.wallet.totalInvested,
    currentValue: overview.wallet.totalCurrentValue,
    totalProfit: overview.wallet.totalProfitLoss,
    totalValuation: overview.wallet.totalProfitLossPercent,
  };
};
