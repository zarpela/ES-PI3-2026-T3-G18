// Desenvolvido por Miguel Afonso Castro de Almeida - RA: 25016044

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getTokenMetrics } from "../repositories/exchangeRepository";

/**
 * Corpo esperado em request.data para consultar as métricas de um token.
 */
type GetTokenMetricsRequest = {
    startupId?: string;
}

/**
 * Callable responsável por obter as métricas de um token específico da carteira
 * do usuário autenticado.
 *
 * Fluxo principal:
 * - exige usuário autenticado;
 * - recebe o ID da startup em `request.data.startupId`;
 * - valida se `startupId` é string;
 * - busca o token na carteira do usuário e compara seu preço médio com o preço
 *   atual da startup.
 *
 * @param request - Solicitação callable do Firebase.
 * @param request.auth.uid - ID do usuário autenticado dono da carteira consultada.
 * @param request.data.startupId - ID da startup cujo token será avaliado.
 *
 * @returns Objeto com o ID da startup e as métricas calculadas:
 * {
 *   startupId: string,
 *   amount: number,
 *   currentPrice: number,
 *   averagePrice: number,
 *   valuation: number,
 *   profit: number
 * }
 *
 * `valuation` é a variação percentual entre o preço atual e o preço médio de
 * aquisição. `profit` é o lucro ou prejuízo absoluto da posição do usuário.
 *
 * @throws HttpsError("unauthenticated") quando não houver usuário autenticado.
 * @throws HttpsError("invalid-argument") quando `startupId` não for uma string válida.
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
