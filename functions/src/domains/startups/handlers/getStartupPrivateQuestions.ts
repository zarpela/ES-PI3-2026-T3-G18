// Desenvolvido por Gabriel Scolfaro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { requireAuthenticatedUser } from "../shared/auth";
import { normalizeString } from "../shared/validation";
import {
    getPrivateQuestions,
    getStartupById,
    userIsInvestor,
} from "../repositories/startupRepository";
import { StartupQuestionResponse } from "../types";

/**
 * Retorna as perguntas privadas de uma startup.
 *
 * Parâmetros esperados no request.data:
 *   - startupId: identificador da startup
 *
 * Requer autenticação e que o usuário seja investidor da startup.
 */
export const getStartupPrivateQuestions = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const user = requireAuthenticatedUser(request);

        const startupId = normalizeString(request.data?.startupId);

        if (!startupId) {
            throw new HttpsError(
                "invalid-argument",
                "Informe o startupId para busca."
            );
        }

        const startup = await getStartupById(startupId);

        if (!startup) {
            throw new HttpsError("not-found", "Startup não encontrada.");
        }

        const isInvestor = await userIsInvestor(startupId, user.uid);

        if (!isInvestor) {
            throw new HttpsError(
                "permission-denied",
                "Apenas investidores desta startup podem acessar perguntas privadas."
            );
        }

        const questions = await getPrivateQuestions(startupId);

        const data: StartupQuestionResponse[] = questions.map(({ id, data: q }) => ({
            id,
            authorUid: q.authorUid,
            text: q.text,
            visibility: q.visibility,
            createdAt: q.createdAt instanceof Timestamp
                ? q.createdAt.toDate().toISOString()
                : null,
            answer: q.answer
                ? {
                    text: q.answer.text,
                    answeredByUid: q.answer.answeredByUid,
                    answeredAt: q.answer.answeredAt instanceof Timestamp
                        ? q.answer.answeredAt.toDate().toISOString()
                        : null,
                }
                : undefined,
        }));

        return {
            count: data.length,
            startupId,
            data,
        };
    }
);