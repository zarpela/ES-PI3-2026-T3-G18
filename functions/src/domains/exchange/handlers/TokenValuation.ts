// Desenvolvido por Miguel Castro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getTokenMetrics } from "../repositories/exchangeRepository";

type GetTokenMetricsRequest = {
    startupId?: string;
}

/**
 * Função callable para obter as métricas de token de uma startup para o usuário.
 *
 * @param request - Solicitação do cliente.
 *   - data.startupId: ID da startup cujo token será avaliado.
 * @returns Retorna o ID da startup e as métricas do token:
 *   - amount: quantidade de tokens do usuário.
 *   - currentPrice: preço atual do token da startup.
 *   - averagePrice: preço médio de aquisição do token.
 *   - valuation: valorização percentual atual.
 *   - profit: lucro absoluto atual.
 */
export const getTokenValuationHandler = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const uid = request.auth?.uid;

        // usuário autenticado
        if (!uid) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado.");
        }

        // evita quebra se request.data for undefined
        const data = (request.data ?? {}) as Partial<GetTokenMetricsRequest>;
        const startupId = data.startupId;

        // valida startupId
        if (!startupId || typeof startupId !== "string") {
            throw new HttpsError("invalid-argument", "Startup inválida.");
        }

        const metrics = await getTokenMetrics(uid, startupId);

        return {
            startupId,
            ...metrics,
        };
    }
);