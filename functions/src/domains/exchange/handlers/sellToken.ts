// Desenvolvido por Miguel Castro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { sellTokens } from "../repositories/exchangeRepository";

/**
 * Padronização do request
 */
type SellTokensRequest = {
    startupId?: string;
    amount?: number;
    pricePerToken?: number;
}

export const sellToken = onCall(
    { region: "southamerica-east1" },
    async (request) => {

        const uid = request.auth?.uid;

        // usuário autenticado
        if (!uid) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado.");
        }

        // evita quebra se request.data for undefined
        const data = (request.data ?? {}) as Partial<SellTokensRequest>;

        const startupId = data.startupId;
        const amount = data.amount;
        const pricePerToken = data.pricePerToken;

        // valida startupId
        if (!startupId || typeof startupId !== "string") {
            throw new HttpsError("invalid-argument", "Startup inválida.");
        }

        // valida quantidade
        if (typeof amount !== "number" || amount <= 0) {
            throw new HttpsError("invalid-argument", "Quantidade inválida.");
        }

        // valida preço
        if (typeof pricePerToken !== "number" || pricePerToken <= 0) {
            throw new HttpsError("invalid-argument", "Preço inválido.");
        }

        // executa venda
        await sellTokens(
            uid,
            startupId,
            amount,
            pricePerToken,
        );

        return {
            message: "Ordem de venda criada com sucesso.",
            data: {startupId, amount, pricePerToken}
        };

    }
);