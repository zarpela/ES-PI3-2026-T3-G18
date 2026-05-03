// Desenvolvido por Gabriel Scolfaro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { normalizeString } from "../shared/validation";
import { getPublicQuestions, getStartupById } from "../repositories/startupRepo";
import { StartupQuestionResponse } from "../types";

/**
 * Retorna as perguntas públicas de uma startup.
 *
 * Parâmetros esperados no request.data:
 *   - startupId: identificador da startup
 *
 * Não requer autenticação — perguntas públicas são visíveis a qualquer usuário.
 */
export const getStartupQuestions = onCall(
    { region: "southamerica-east1" },
    async (request) => {
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

        const questions = await getPublicQuestions(startupId);

        const data: StartupQuestionResponse[] = questions.map(({ id, data: q }) => ({
            id,
            authorUid: q.authorUid,
            authorEmail: q.authorEmail,
            text: q.text,
            visibility: q.visibility,
            createdAt: q.createdAt instanceof Timestamp
                ? q.createdAt.toDate().toISOString()
                : null,
            answer: q.answer
                ? {
                    text: q.answer.text,
                    answeredByUid: q.answer.answeredByUid,
                    answeredByEmail: q.answer.answeredByEmail,
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