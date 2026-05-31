// Desenvolvido por Miguel Afonso Castro de Almeida - RA: 25016044

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getUserInvestmentsMetrics } from "../repositories/exchangeRepository";

/**
 * Callable responsável por retornar o resumo completo dos investimentos do
 * usuário autenticado.
 *
 * Fluxo principal:
 * - exige usuário autenticado;
 * - busca todos os tokens da carteira do usuário;
 * - calcula métricas individuais por startup e os totais consolidados da carteira.
 *
 * @param request - Solicitação callable do Firebase.
 * @param request.auth.uid - ID do usuário autenticado dono da carteira consultada.
 *
 * @returns Resumo de investimentos no formato:
 * {
 *   investments: [
 *     {
 *       startupId: string,
 *       amount: number,
 *       currentPrice: number,
 *       averagePrice: number,
 *       valuation: number,
 *       profit: number
 *     }
 *   ],
 *   investedValue: number,
 *   currentValue: number,
 *   totalProfit: number,
 *   totalValuation: number
 * }
 *
 * `investedValue` representa o custo total de aquisição dos tokens,
 * `currentValue` representa o valor atual da carteira, `totalProfit` é o lucro
 * absoluto e `totalValuation` é a valorização percentual consolidada.
 *
 * @throws HttpsError("unauthenticated") quando o usuário não estiver autenticado.
 */
export const getUserInvestmentsMetricsHandler = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const uid = request.auth?.uid;

        if (!uid) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado.");
        }

        return await getUserInvestmentsMetrics(uid);
    }
);
