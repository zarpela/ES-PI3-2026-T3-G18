// Desenvolvido por Miguel Castro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { buyTokens } from "../repositories/exchangeRepository";

/**
 * Padronização do request
 */
type BuyTokensRequest = {
    startupId?: string;
    amount?: number;
}

/**
 * Função callable para comprar tokens.
 *
 * @param request - Solicitação do cliente contendo os dados de compra.
 *   - data.startupId: ID da startup cujos tokens serão comprados.
 *   - data.amount: Quantidade de tokens a comprar.
 * @returns Retorna mensagem de sucesso e os dados da compra.
 */
export const buyToken = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const uid = request.auth?.uid;

        if (!uid) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado.");
        }

        // evita quebra se request.data for undefined
        const data = (request.data ?? {}) as Partial<BuyTokensRequest>;

        const startupId = data.startupId;
        const amount = data.amount;

        // valida startupId
        if (!startupId || typeof startupId !== "string") {
            throw new HttpsError("invalid-argument", "Startup inválida.");
        }

        // valida quantidade
        if (typeof amount !== "number" || amount <= 0){
            throw new HttpsError("invalid-argument", "Quantidade inválida.");
        }

        // executa compra
        await buyTokens(uid, startupId, amount);

        return {
            message: "Compra realizada com sucesso.",
            data: {startupId, amount}
        };

});