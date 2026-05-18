// Desenvolvido por Miguel Castro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getUserInvestmentsMetrics } from "../repositories/exchangeRepository";

/**
 * Função callable para retornar o resumo de investimentos
 * do usuário autenticado.
 *
 * @param request Contexto da requisição fornecido pelo Firebase Functions.
 * @returns Resumo de investimentos do usuário com lista de investimentos,
 *   valores totais e valorização.
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