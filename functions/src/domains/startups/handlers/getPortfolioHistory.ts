// Desenvolvido por Gabriel Scolfaro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import { getTokenPriceHistory } from "../repositories/startupRepository";
import { normalizeString } from "../shared/validation";

/**
 * Períodos suportados para visualização do histórico de valorização.
 */
type Period = "daily" | "weekly" | "monthly" | "6months" | "ytd";

const allowedPeriods: Period[] = ["daily", "weekly", "monthly", "6months", "ytd"];

/**
 * Retorna a data de início correspondente ao período informado.
 */
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


/**
 * Callable que retorna o histórico do valor total da carteira (portfólio) do usuário em um período.
 *
 * Parâmetros esperados em request.data:
 * - period: "daily" | "weekly" | "monthly" | "6months" | "ytd"
 *
 * Requer autenticação.
 *
 * @returns {
 * period: string,
 * startDate: string,   // ISO
 * count: number,
 * data: { totalValue: number, timestamp: string }[]
 * }
 */
export const getPortfolioHistoryHandler = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const uid = request.auth?.uid;

        if (!uid) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado.");
        }

        const data = (request.data ?? {}) as Record<string, unknown>;
        const period = normalizeString(data.period) as Period | undefined;

        if (!period || !allowedPeriods.includes(period)) {
            throw new HttpsError(
                "invalid-argument",
                "Período inválido. Use: daily, weekly, monthly, 6months ou ytd."
            );
        }

        const startDate = getStartDateForPeriod(period);
        const now = new Date();

        // 1. Busca todas as transações de compra e venda do usuário para reconstruir o saldo histórico
        const txSnapshot = await db
            .collection("wallet")
            .doc(uid)
            .collection("transactions")
            .where("type", "in", ["BUY", "SELL"])
            .orderBy("createdAt", "asc")
            .get();

        const parsedTransactions = txSnapshot.docs.map((doc) => {
            const tx = doc.data();
            return {
                startupId: tx.startupId as string,
                type: tx.type as "BUY" | "SELL",
                quantity: Number(tx.quantity),
                timestamp: (tx.createdAt as Timestamp).toDate().getTime(),
            };
        });

        // 2. Identifica quais startups o usuário já movimentou alguma vez
        const startupIds = Array.from(new Set(parsedTransactions.map((tx) => tx.startupId).filter(Boolean)));

        // 3. Busca o histórico de preços APENAS das startups que o usuário possui/possuiu
        const priceHistories: Record<string, { price: number; timestamp: number }[]> = {};
        
        await Promise.all(
            startupIds.map(async (startupId) => {
                const history = await getTokenPriceHistory(startupId, startDate);
                priceHistories[startupId] = history.map(h => ({
                    price: h.price,
                    timestamp: (h.createdAt as Timestamp).toDate().getTime()
                }));
            })
        );

        // 4. Cria os "pontos" (ticks) do gráfico para o período solicitado
        const ticks: Date[] = [];
        const tickInterval = period === "daily" 
            ? 4 * 60 * 60 * 1000  // A cada 4 horas para o gráfico diário
            : 24 * 60 * 60 * 1000; // A cada 1 dia para o resto

        for (let d = startDate.getTime(); d <= now.getTime(); d += tickInterval) {
            ticks.push(new Date(d));
        }
        ticks.push(now); // Garante que o momento atual seja o último ponto do gráfico

        // 5. Calcula o valor total da carteira em CADA ponto do gráfico
        const chartData = ticks.map((tick) => {
            const tickTime = tick.getTime();
            let totalPortfolioValue = 0;

            for (const startupId of startupIds) {
                // Filtra as transações que aconteceram ANTES deste ponto do gráfico para saber o saldo
                const pastTxs = parsedTransactions.filter(
                    (tx) => tx.startupId === startupId && tx.timestamp <= tickTime
                );

                let tokenBalance = 0;
                for (const tx of pastTxs) {
                    if (tx.type === "BUY") tokenBalance += tx.quantity;
                    if (tx.type === "SELL") tokenBalance -= tx.quantity;
                }

                // Se o usuário tinha tokens neste momento, descobre quanto eles valiam
                if (tokenBalance > 0) {
                    const history = priceHistories[startupId] || [];
                    const pastPrices = history.filter((p) => p.timestamp <= tickTime);
                    
                    let tokenPriceAtTheTime = 0;
                    if (pastPrices.length > 0) {
                        tokenPriceAtTheTime = pastPrices[pastPrices.length - 1].price; // Pega o preço mais recente antes do tick
                    } else if (history.length > 0) {
                        tokenPriceAtTheTime = history[0].price; // Fallback para o primeiro preço salvo
                    }

                    totalPortfolioValue += tokenBalance * tokenPriceAtTheTime;
                }
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
    }
);