// Desenvolvido por Miguel Castro

import { Timestamp } from "firebase-admin/firestore";
import { db } from "../../../shared/firebase";
import { HttpsError } from "firebase-functions/https";
import { Wallet } from "../../users/types";
import { StartupDoc } from "../../startups/types";
import { SellOrder, Token } from "../types";

const walletCol = db.collection("wallets");
const startupCol = db.collection("startups");
const sellOrdersCol = db.collection("sellOrders");

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

    // atualiza carteira
    transaction.update(walletRef, {
        balance: wallet.balance - totalPrice,
        lastUpdated: Timestamp.now(),
    });

    // atualiza token
    transaction.set(tokenRef, {
        amount: currentAmount + amount,
        averagePrice: newAveragePrice,
        lastUpdated: Timestamp.now(),
    }, { merge: true } // merge para não sobrescrever caso já tenha tokens
    );

    // atualiza startup
    transaction.update(startupRef, {
        raisedCapital: startup.raisedCapital + totalPrice,
        totalEmittedTokens: startup.totalEmittedTokens + amount,
    });

  });
}

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

        const order: SellOrder = {
            id: orderRef.id,
            ownerId: uid,
            startupId,
            startupName: startup.name,
            amount,
            pricePerToken,
            averagePrice: token.averagePrice,
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
        const newAveragePrice =(currentAveragePrice*currentAmount+totalPrice) / (currentAmount+order.amount);

        // desconta comprador
        transaction.update(buyerWalletRef,
            { balance: buyerWallet.balance - totalPrice, lastUpdated: Timestamp.now(),}
        );

        // paga vendedor
        transaction.update(sellerWalletRef,
            { balance: sellerWallet.balance + totalPrice, lastUpdated: Timestamp.now(),}
        );

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
    });
}