// Desenvolvido por Miguel Castro

import { Timestamp } from "firebase-admin/firestore";
import { db } from "../../../shared/firebase";
import { HttpsError } from "firebase-functions/https";
import { Wallet } from "../../users/types";
import { StartupDoc } from "../../startups/types";
import { SellOrder, Token, TokenMetrics, UserInvestment, UserInvestmentsSummary } from "../types";

const walletCol = db.collection("wallet");
const startupCol = db.collection("startups");
const sellOrdersCol = db.collection("sellOrders");

/**
 * Compra tokens de uma startup para a carteira do usuário.
 *
 * @param uid - ID do usuário comprador.
 * @param startupId - ID da startup cujos tokens serão comprados.
 * @param amount - Quantidade de tokens a comprar. Deve ser maior que zero.
 * @returns Promise<void> quando a compra for concluída com sucesso.
 */
export async function buyTokens(
    uid: string,
    startupId: string,
    amount: number,
): Promise<void> {

  if (amount <= 0) {
    throw new HttpsError("invalid-argument", "Quantidade inválida");
  }

  const walletRef = walletCol.doc(uid);
  const tokenRef = walletRef.collection("tokens").doc(startupId);

  const startupRef = startupCol.doc(startupId);

  // transaction garante que todas as operações sejam feitas
  // de uma só vez ou nenhuma no banco
  await db.runTransaction(async (transaction) => {
    const startupSnap = await transaction.get(startupRef);

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
}

/**
 * Cria uma ordem de venda de tokens a partir da carteira do usuário.
 *
 * @param uid - ID do usuário vendedor.
 * @param startupId - ID da startup cujos tokens serão vendidos.
 * @param amount - Quantidade de tokens a vender. Deve ser maior que zero.
 * @param pricePerToken - Preço por token definido para a ordem. Deve ser maior que zero.
 * @returns Promise<void> quando a ordem de venda for criada com sucesso.
 */
export async function sellTokens(
    uid: string,
    startupId: string,
    amount: number,
    pricePerToken: number,
): Promise<void> {
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
    });

}

/**
 * Retorna todas as ordens de venda abertas
 */
/**
 * Retorna todas as ordens de venda abertas.
 *
 * @returns Promise<SellOrder[]> com as ordens de venda em estado "open".
 */
export async function getSellOrders(): Promise<SellOrder[]> {
    try {
        // busca ordens abertas
        const snapshot = await sellOrdersCol
        .where("status", "==", "open")
        .get();

        return snapshot.docs.map((doc) => ({
            id: doc.id,
            ...(doc.data() as SellOrder),
        }));
    } catch (e) {
        throw new HttpsError("internal", "Erro ao buscar ordens de venda.");
    }
}

/**
 * Compra uma ordem de venda aberta para um comprador específico.
 *
 * @param buyerId - ID do usuário que está comprando a ordem.
 * @param orderId - ID da ordem de venda a ser comprada.
 * @returns Promise<void> quando a compra da ordem for concluída com sucesso.
 */
export async function buySellOrder(
    buyerId: string,
    orderId: string,
): Promise<void> {
    const orderRef = sellOrdersCol.doc(orderId);
    const buyerWalletRef = walletCol.doc(buyerId);

    await db.runTransaction(async (transaction) => {

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
    });
}

/**
 * Retorna métricas de token para a carteira do usuário e a startup informada.
 *
 * @param uid - ID do usuário dono da carteira onde o token está armazenado.
 * @param startupId - ID da startup referente ao token.
 * @returns Promise<TokenMetrics> com métricas do token:
 *   - amount: quantidade de tokens do usuário.
 *   - currentPrice: preço atual do token da startup.
 *   - averagePrice: preço médio de aquisição do token pelo usuário.
 *   - valuation: valorização percentual atual.
 *   - profit: lucro absoluto atual da posição de token.
 *   - Retorna 0 em valuation se o `averagePrice` do token for menor ou igual a zero.
 *   - O valor retornado é arredondado para 2 casas decimais.
 * @throws HttpsError("not-found") se o token ou a startup não existirem.
 * @throws HttpsError("internal") em caso de erro interno ao calcular as métricas.
 */
export async function getTokenMetrics(
    uid: string,
    startupId: string,
): Promise<TokenMetrics> {
    try {
        const tokenRef = walletCol
            .doc(uid)
            .collection("tokens")
            .doc(startupId);

        const startupRef = startupCol.doc(startupId);
        const startupSnap = await startupRef.get();
        const tokenSnap = await tokenRef.get();
        
        // token existe?
        if (!tokenSnap.exists) {
            throw new HttpsError("not-found", "Token não encontrado.");
        }

        // startup existe?
        if (!startupSnap.exists) {
            throw new HttpsError("not-found", "Startup não encontrada.");
        }

        const token = tokenSnap.data() as Token;
        const startup = startupSnap.data() as StartupDoc;
        const currentPrice = startup.tokenPrice;
        const averagePrice = token.averagePrice;
        const amount = token.amount;

        let valuation = 0;

        // evita divisão por zero
        if (averagePrice > 0) {
            valuation = ((currentPrice - averagePrice) / averagePrice) * 100;
        }

        const profit = (currentPrice - averagePrice) * amount;

        // arredonda 2 casas
        return {
            amount,
            currentPrice,
            averagePrice,
            valuation: Number(valuation.toFixed(2)),
            profit: Number(profit.toFixed(2)),
        };

    } catch (e) {
        throw new HttpsError("internal", "Erro ao calcular métricas do token.");
    }
}

/**
 * Retorna o resumo dos investimentos do usuário.
 *
 * @param uid ID do usuário dono da carteira.
 * @returns Promise<UserInvestmentsSummary> com os investimentos,
 *   valores totais e valorização da carteira.
 * @throws HttpsError("not-found") se a carteira não existir.
 * @throws HttpsError("internal") em caso de erro interno.
 */
export async function getUserInvestmentsMetrics(
    uid: string,
): Promise<UserInvestmentsSummary> {
    try {
        const walletRef = walletCol.doc(uid);
        const walletSnap = await walletRef.get();

        if (!walletSnap.exists) {
            throw new HttpsError("not-found", "Carteira não encontrada.");
        }

        const tokensSnap = await walletRef.collection("tokens").get();
        const investments: UserInvestment[] = [];

        let investedValue = 0;
        let currentValue = 0;
        let totalProfit = 0;

        for (const doc of tokensSnap.docs) {
            const startupId = doc.id;
            const token = doc.data() as Token;

            const startupSnap = await startupCol.doc(startupId).get();
            if (!startupSnap.exists) {
                continue;
            }

            const startup = startupSnap.data() as StartupDoc;
            const currentPrice = startup.tokenPrice;
            const averagePrice = token.averagePrice;
            const amount = token.amount;

            const investmentCost = averagePrice * amount;
            const investmentCurrentValue = currentPrice * amount;
            const profit = investmentCurrentValue - investmentCost;
            const valuation = investmentCost > 0
                ? Number(((profit / investmentCost) * 100).toFixed(2))
                : 0;

            investedValue += investmentCost;
            currentValue += investmentCurrentValue;
            totalProfit += profit;

            investments.push({
                startupId,
                amount,
                currentPrice,
                averagePrice,
                valuation,
                profit: Number(profit.toFixed(2)),
            });
        }

        const totalValuation = investedValue > 0
            ? Number(((totalProfit / investedValue) * 100).toFixed(2))
            : 0;

        return {
            investments, // a lista de investimentos e suas métricas individuais
            
            // resumo dos valores totais da carteira, calculando todos os
            // investimentos juntos 
            investedValue: Number(investedValue.toFixed(2)),
            currentValue: Number(currentValue.toFixed(2)),
            totalProfit: Number(totalProfit.toFixed(2)),
            totalValuation,
        };
    } catch (e) {
        throw new HttpsError("internal", "Erro ao buscar investimentos.");
    }
}