// Desenvolvido por Miguel Castro
//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import {HttpsError} from "firebase-functions/v2/https";
import {
  buyMarketplaceOffer,
  buyStartupTokens,
  createSellOffer,
  createServiceError,
  getTokenMetrics as getWalletTokenMetrics,
  getUserInvestmentsMetrics as getWalletInvestmentsMetrics,
  listMarketplaceOffers,
} from "../../../services/walletService";
import {
  SellOrder,
  TokenMetrics,
  UserInvestmentsSummary,
} from "../types";

function toHttpsError(error: unknown): HttpsError {
  const status = (error as {status?: unknown}).status;
  const message = error instanceof Error ?
    error.message :
    "Erro ao processar operacao de mercado.";

  if (status === 400) {
    return new HttpsError("invalid-argument", message);
  }

  if (status === 401) {
    return new HttpsError("unauthenticated", message);
  }

  if (status === 403) {
    return new HttpsError("permission-denied", message);
  }

  if (status === 404) {
    return new HttpsError("not-found", message);
  }

  return new HttpsError("internal", message);
}

export async function buyTokens(
  uid: string,
  startupId: string,
  amount: number,
): Promise<void> {
  try {
    await buyStartupTokens({
      authenticatedUserId: uid,
      startupId,
      quantity: amount,
    });
  } catch (error) {
    throw toHttpsError(error);
  }
}

export async function sellTokens(
  uid: string,
  startupId: string,
  amount: number,
  pricePerToken: number,
): Promise<void> {
  try {
    await createSellOffer({
      authenticatedUserId: uid,
      startupId,
      quantity: amount,
      unitPrice: pricePerToken,
    });
  } catch (error) {
    throw toHttpsError(error);
  }
}

export async function getSellOrders(): Promise<SellOrder[]> {
  try {
    const offers = await listMarketplaceOffers();

    return offers.map((offer) => ({
      id: offer.id,
      ownerId: offer.sellerId,
      sellerId: offer.sellerId,
      sellerName: offer.sellerName,
      startupId: offer.startupId,
      startupName: offer.startupName,
      amount: offer.remainingQuantity,
      quantity: offer.quantity,
      remainingQuantity: offer.remainingQuantity,
      pricePerToken: offer.unitPrice,
      unitPrice: offer.unitPrice,
      averagePrice: offer.unitPrice,
      createdAt: offer.createdAt,
      updatedAt: offer.updatedAt,
      status: offer.status,
      totalValue: offer.totalValue,
      type: "sell",
    })) as SellOrder[];
  } catch (error) {
    throw toHttpsError(error);
  }
}

export async function buySellOrder(
  buyerId: string,
  orderId: string,
  amount?: number,
): Promise<void> {
  try {
    const quantity = amount ?? (await listMarketplaceOffers())
      .find((offer) => offer.id === orderId)?.remainingQuantity;

    if (!quantity) {
      invalidExchangeRequest("Quantidade da oferta invalida.");
    }

    await buyMarketplaceOffer({
      authenticatedUserId: buyerId,
      offerId: orderId,
      quantity,
    });
  } catch (error) {
    throw toHttpsError(error);
  }
}

export async function getTokenMetrics(
  uid: string,
  startupId: string,
): Promise<TokenMetrics> {
  try {
    return await getWalletTokenMetrics(uid, startupId);
  } catch (error) {
    throw toHttpsError(error);
  }
}

export async function getUserInvestmentsMetrics(
  uid: string,
): Promise<UserInvestmentsSummary> {
  try {
    return await getWalletInvestmentsMetrics(uid);
  } catch (error) {
    throw toHttpsError(error);
  }
}

export function invalidExchangeRequest(message: string): never {
  throw createServiceError(400, message);
}
