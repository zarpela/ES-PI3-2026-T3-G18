// Desenvolvido por Miguel Castro
// Abdallah El-Khatib

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

<<<<<<< HEAD
    if (!startupSnap.exists) {
        throw new HttpsError("not-found", "Startup não encontrada.");
    }

    const walletSnap = await transaction.get(walletRef);

    if (!walletSnap.exists) {
        throw new HttpsError("not-found", "Carteira não encontrada.");
    }

    const startup = startupSnap.data() as StartupDoc;
    const wallet = walletSnap.data() as Wallet;
    const totalPrice = startup.tokenPrice*amount;

    if (wallet.balance < totalPrice) {
        throw new HttpsError("failed-precondition", "Saldo insuficiente");
    }

    // token atual
    const tokenSnap = await transaction.get(tokenRef);

    let currentAmount = 0;
    let currentPrice = 0;

    // se o token já existe, pega a quantidade atual para somar
    if (tokenSnap.exists) {
        const token = tokenSnap.data() as Token;
        currentAmount = token.amount;
        currentPrice = token.averagePrice;
    }

    const newAveragePrice = (currentPrice*currentAmount + totalPrice) / (currentAmount + amount);

    // calculo de valorização
    const liquidity = Math.max(startup.raisedCapital, 1000);
    const impact = totalPrice / liquidity;

    // limita a variação
    const maxImpact = 0.05;
    const clampedImpact = Math.min(impact, maxImpact);

    // novo valor do token
    const newTokenPrice = startup.tokenPrice * (1 + clampedImpact);

    // atualiza carteira
    transaction.update(walletRef, {
        balance: wallet.balance - totalPrice,
        lastUpdated: Timestamp.now(),
    });

    // atualiza token
    transaction.set(tokenRef, {
        amount: currentAmount + amount,
        averagePrice: Number(newAveragePrice.toFixed(2)),
        lastUpdated: Timestamp.now(),
    }, { merge: true } // merge para não sobrescrever caso já tenha tokens
    );

    // atualiza startup
    transaction.update(startupRef, {
        raisedCapital: startup.raisedCapital + totalPrice,
        totalEmittedTokens: startup.totalEmittedTokens + amount,
        tokenPrice: Number(newTokenPrice.toFixed(2)),
    });

  });
=======
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
>>>>>>> feature/integracao-marketplace-wallet-perguntas
}

export async function sellTokens(
  uid: string,
  startupId: string,
  amount: number,
  pricePerToken: number,
): Promise<void> {
<<<<<<< HEAD
    if (amount <= 0) {
        throw new HttpsError("invalid-argument", "Quantidade inválida.");
    }

    if (pricePerToken <= 0) {
        throw new HttpsError("invalid-argument", "Preço inválido.");
    }

    const walletRef = walletCol.doc(uid);
    const tokenRef = walletRef.collection("tokens").doc(startupId);
    const startupRef = startupCol.doc(startupId);
    const orderRef = sellOrdersCol.doc();

    await db.runTransaction(async (transaction) => {

        // garante que a startup existe ainda existe antes de tentar vender
        const startupSnap = await transaction.get(startupRef);
        
        if (!startupSnap.exists) {
            throw new HttpsError("not-found", "Startup não encontrada.");
        }

        const startup = startupSnap.data() as StartupDoc;
        const tokenSnap = await transaction.get(tokenRef);

        if (!tokenSnap.exists) {
            throw new HttpsError("failed-precondition", "Token não encontrado.");
        }

        const token = tokenSnap.data() as Token;

        // tokens suficientes?
        if (token.amount < amount) {
            throw new HttpsError("failed-precondition", "Quantidade insuficiente.");
        }

        const remaining = token.amount - amount;

        // remove tokens da carteira
        if (remaining <= 0) {
            transaction.delete(tokenRef);
        } else {
            transaction.update(tokenRef, 
                {amount: remaining, 
                lastUpdated: Timestamp.now(),});
        }
        // impacto negativo no preço
        const totalPrice = startup.tokenPrice * amount;
        const liquidity = Math.max(startup.raisedCapital, 1000);
        const impact = totalPrice / liquidity;

        // limita variacao
        const maxImpact = 0.05;
        const clampedImpact = Math.min(impact, maxImpact);

        // novo preço do token
        const newTokenPrice = startup.tokenPrice * (1 - clampedImpact);
        
        // evita preço negativo/zero
        const safeTokenPrice = Math.max(newTokenPrice, 0.01);

        // atualiza startup
        transaction.update(startupRef, {
            tokenPrice: Number(safeTokenPrice.toFixed(2)),
        });
        
        const order: SellOrder = {
            id: orderRef.id,
            ownerId: uid,
            startupId,
            startupName: startup.name,
            amount,
            pricePerToken: Number(pricePerToken.toFixed(2)),
            averagePrice: Number(token.averagePrice.toFixed(2)),
            createdAt:Timestamp.now(),
            status: "open",
        };

        // cria ordem de venda
        transaction.set(orderRef, order);
=======
  try {
    await createSellOffer({
      authenticatedUserId: uid,
      startupId,
      quantity: amount,
      unitPrice: pricePerToken,
>>>>>>> feature/integracao-marketplace-wallet-perguntas
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

<<<<<<< HEAD
        // busca ordem
        const orderSnap = await transaction.get(orderRef);
        
        if (!orderSnap.exists) {
            throw new HttpsError("not-found","Ordem não encontrada.");
        }
        
        const order = orderSnap.data() as SellOrder;

        // a ordem armazena o id da startup a qual pertence
        const startupRef = startupCol.doc(order.startupId);
        const startupSnap = await transaction.get(startupRef);
        if (!startupSnap.exists) {
            throw new HttpsError("not-found", "Startup não encontrada.");
        }
        


        // ordem precisa estar aberta
        if (order.status !== "open") {
            throw new HttpsError("failed-precondition", "Ordem indisponível.");
        }

        // impede comprar própria ordem
        if (order.ownerId === buyerId) {
            throw new HttpsError("failed-precondition", "Não é possível comprar sua própria ordem.");
        }

        const sellerWalletRef = walletCol.doc(order.ownerId);

        // busca carteiras
        const buyerWalletSnap = await transaction.get(buyerWalletRef);

        const sellerWalletSnap = await transaction.get(sellerWalletRef);

        if (!buyerWalletSnap.exists) {
            throw new HttpsError("not-found","Carteira do comprador não encontrada.");
        }

        if (!sellerWalletSnap.exists) {
            throw new HttpsError("not-found", "Carteira do vendedor não encontrada.");
        }

        const buyerWallet = buyerWalletSnap.data() as Wallet;
        const sellerWallet = sellerWalletSnap.data() as Wallet;

        // valor total
        const totalPrice = order.amount * order.pricePerToken;

        // saldo suficiente?
        if (buyerWallet.balance < totalPrice) {
            throw new HttpsError("failed-precondition", "Saldo insuficiente.");
        }

        // token comprador
        const buyerTokenRef = buyerWalletRef.collection("tokens").doc(order.startupId);
        const buyerTokenSnap = await transaction.get(buyerTokenRef);

        let currentAmount = 0;
        let currentAveragePrice = 0;

        // comprador já possui token?
        if (buyerTokenSnap.exists) {
            const token = buyerTokenSnap.data() as Token;
            currentAmount = token.amount;
            currentAveragePrice = token.averagePrice;
        }

        // novo preço médio
        const denominator = currentAmount + order.amount; // Evitar comportamento indesejado
        const newAveragePrice = denominator > 0
            ? Number(((currentAveragePrice * currentAmount+ totalPrice) / denominator).toFixed(2))
            : 0;

        // desconta comprador
        transaction.update(buyerWalletRef,
            { balance: buyerWallet.balance - totalPrice, lastUpdated: Timestamp.now(),}
        );

        // paga vendedor
        transaction.update(sellerWalletRef,
            { balance: sellerWallet.balance + totalPrice, lastUpdated: Timestamp.now(),}
        );

        const startup = startupSnap.data() as StartupDoc;
        const liquidity = Math.max(startup.raisedCapital, 1000);
        const impact = totalPrice / liquidity;
        const maxImpact = 0.05;
        const clampedImpact = Math.min(impact, maxImpact);
        const newTokenPrice = (startup.tokenPrice * (1 + clampedImpact));

        // adiciona tokens comprador
        transaction.set(buyerTokenRef,
        {
            amount: currentAmount + order.amount,
            averagePrice: newAveragePrice,
            lastUpdated: Timestamp.now(),
        },
        { merge: true } // merge para não sobrescrever caso já tenha tokens
    );

        // finaliza ordem
        transaction.update(orderRef, {status: "completed",});

        transaction.update(startupRef, {
            tokenPrice: Number(newTokenPrice.toFixed(2)),
        });
=======
    await buyMarketplaceOffer({
      authenticatedUserId: buyerId,
      offerId: orderId,
      quantity,
>>>>>>> feature/integracao-marketplace-wallet-perguntas
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
