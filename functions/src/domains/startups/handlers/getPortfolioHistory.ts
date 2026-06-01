// Desenvolvido por Gabriel Scolfaro de Azeredo - RA: 25006194
//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {db} from "../../../shared/firebase";
import {getTokenPriceHistory} from "../repositories/startupRepository";
import {normalizeString} from "../shared/validation";

type Period = "daily" | "weekly" | "monthly" | "6months" | "ytd";

type WalletTransaction = {
  quantity: number;
  startupId: string;
  timestamp: number;
  type: string;
};

const allowedPeriods: Period[] = [
  "daily",
  "weekly",
  "monthly",
  "6months",
  "ytd",
];

function getStartDateForPeriod(period: Period): Date {
  const now = new Date();

  switch (period) {
  case "daily":
    return new Date(now.getTime() - 24 * 60 * 60 * 1000);
  case "weekly":
    return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  case "monthly":
    return new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
  case "6months":
    return new Date(now.getTime() - 180 * 24 * 60 * 60 * 1000);
  case "ytd":
    return new Date(now.getFullYear(), 0, 1);
  }
}

function timestampToMillis(value: unknown): number | null {
  if (value instanceof Timestamp) {
    return value.toDate().getTime();
  }

  if (
    value &&
    typeof value === "object" &&
    "toDate" in value &&
    typeof (value as {toDate: () => Date}).toDate === "function"
  ) {
    return (value as {toDate: () => Date}).toDate().getTime();
  }

  const parsed = Date.parse(String(value ?? ""));
  return Number.isNaN(parsed) ? null : parsed;
}

function transactionDelta(type: string, quantity: number): number {
  const normalized = type.toUpperCase();

  if (normalized === "BUY" || normalized === "BUY_MARKETPLACE") {
    return quantity;
  }

  if (normalized === "SELL" || normalized === "SELL_MARKETPLACE") {
    return -quantity;
  }

  return 0;
}

async function getFallbackPrice(startupId: string): Promise<number> {
  const snapshot = await db.collection("startups").doc(startupId).get();

  if (!snapshot.exists) {
    return 0;
  }

  const data = snapshot.data() ?? {};
  const directPrice = Number(
    data.tokenPrice ?? data.unitPrice ?? data.valorToken ?? 0,
  );

  if (Number.isFinite(directPrice) && directPrice > 0) {
    return directPrice;
  }

  const targetCapital = Number(data.targetCapital ?? 0);
  const emittedTokens = Number(data.totalEmittedTokens ?? 0);

  if (targetCapital > 0 && emittedTokens > 0) {
    return targetCapital / emittedTokens;
  }

  return 0;
}

export const getPortfolioHistory = onCall(
  {region: "southamerica-east1"},
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError("unauthenticated", "Usuario nao autenticado.");
    }

    const period = normalizeString(request.data?.period) as Period | undefined;

    if (!period || !allowedPeriods.includes(period)) {
      throw new HttpsError(
        "invalid-argument",
        "Periodo invalido. Use: daily, weekly, monthly, 6months ou ytd.",
      );
    }

    const startDate = getStartDateForPeriod(period);
    const now = new Date();
    const transactionSnapshot = await db
      .collection("wallets")
      .doc(uid)
      .collection("transactions")
      .orderBy("createdAt", "asc")
      .get();
    const parsedTransactions: WalletTransaction[] = transactionSnapshot.docs
      .map((doc) => {
        const tx = doc.data();
        const timestamp = timestampToMillis(tx.createdAt);

        if (!timestamp) {
          return null;
        }

        return {
          startupId: normalizeString(tx.startupId) ?? "",
          type: normalizeString(tx.type)?.toUpperCase() ?? "",
          quantity: Number(tx.quantity ?? 0),
          timestamp,
        };
      })
      .filter((tx): tx is WalletTransaction =>
        Boolean(tx?.startupId && tx.quantity > 0),
      );
    const startupIds = Array.from(
      new Set(parsedTransactions.map((tx) => tx.startupId)),
    );

    if (startupIds.length === 0) {
      return {
        period,
        startDate: startDate.toISOString(),
        count: 0,
        data: [],
      };
    }

    const priceHistories: Record<
      string,
      {price: number; timestamp: number}[]
    > = {};

    await Promise.all(startupIds.map(async (startupId) => {
      const [history, fallbackPrice] = await Promise.all([
        getTokenPriceHistory(startupId, startDate),
        getFallbackPrice(startupId),
      ]);
      const parsedHistory = history
        .map((entry) => ({
          price: Number(entry.price ?? 0),
          timestamp: timestampToMillis(entry.createdAt) ?? 0,
        }))
        .filter((entry) => entry.price > 0 && entry.timestamp > 0);

      if (parsedHistory.length === 0 && fallbackPrice > 0) {
        parsedHistory.push({
          price: fallbackPrice,
          timestamp: startDate.getTime(),
        });
      }

      priceHistories[startupId] = parsedHistory;
    }));

    const ticks: Date[] = [];
    const tickInterval = period === "daily" ?
      4 * 60 * 60 * 1000 :
      24 * 60 * 60 * 1000;

    for (
      let tick = startDate.getTime();
      tick <= now.getTime();
      tick += tickInterval
    ) {
      ticks.push(new Date(tick));
    }

    ticks.push(now);

    const chartData = ticks.map((tick) => {
      const tickTime = tick.getTime();
      let totalPortfolioValue = 0;

      for (const startupId of startupIds) {
        const tokenBalance = parsedTransactions
          .filter((tx) => tx.startupId === startupId && tx.timestamp <= tickTime)
          .reduce(
            (total, tx) => total + transactionDelta(tx.type, tx.quantity),
            0,
          );

        if (tokenBalance <= 0) {
          continue;
        }

        const history = priceHistories[startupId] ?? [];
        const pastPrices = history.filter((price) => price.timestamp <= tickTime);
        const priceAtTick = pastPrices.length > 0 ?
          pastPrices[pastPrices.length - 1].price :
          history[0]?.price ?? 0;

        totalPortfolioValue += tokenBalance * priceAtTick;
      }

      return {
        timestamp: tick.toISOString(),
        totalValue: Number(totalPortfolioValue.toFixed(2)),
      };
    });

    return {
      period,
      startDate: startDate.toISOString(),
      count: chartData.length,
      data: chartData,
    };
  },
);

