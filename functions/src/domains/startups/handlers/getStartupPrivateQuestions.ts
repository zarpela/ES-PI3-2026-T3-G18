// Desenvolvido por Gabriel Scolfaro de Azeredo - RA: 25006194

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";

import { requireAuthenticatedUser } from "../shared/auth";
import { normalizeString } from "../shared/validation";
import {
    getPrivateQuestions,
    getStartupById,
    userCanReadAllPrivateQuestions,
    userIsInvestor,
} from "../repositories/startupRepository";
import { StartupQuestionResponse } from "../types";

/**
 * Retorna as perguntas privadas de uma startup.
 *
 * Parâmetros esperados no request.data:
 * - startupId: identificador da startup
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

        //feito por Abdallah Ali Borges El-Khatib - RA: 25018711
        const [isInvestor, canReadAll] = await Promise.all([
            userIsInvestor(startupId, user.uid),
            userCanReadAllPrivateQuestions(startupId, user.uid),
        ]);

        if (!isInvestor && !canReadAll) {
            throw new HttpsError(
                "permission-denied",
                "Apenas investidores desta startup podem acessar perguntas privadas."
            );
        }

        const questions = await getPrivateQuestions(startupId, user.uid, canReadAll);

        const data: StartupQuestionResponse[] = questions.map(({ id, data: q }) => {
            // Lógica segura para lidar com Timestamp, FieldValue ou Data nula
            let createdAtString = new Date().toISOString();
            if (q.createdAt) {
                if (q.createdAt instanceof Timestamp) {
                    createdAtString = q.createdAt.toDate().toISOString();
                } else if ((q.createdAt as any)._seconds) {
                    // Trata caso o timestamp chegue desserializado
                    createdAtString = new Date((q.createdAt as any)._seconds * 1000).toISOString();
                } else {
                    // Força a conversão bypassando o erro do TypeScript de FieldValue
                    try {
                        createdAtString = new Date(q.createdAt as any).toISOString();
                    } catch (e) {
                        // Mantém a data atual como fallback se der falha no parse
                    }
                }
            }

            return {
                id,
                authorId: q.authorId ?? q.authorUid,
                authorName: q.authorName ?? "Usuário",
                authorUid: q.authorUid,
                isAnswered: q.isAnswered ?? Boolean(q.answer),
                question: q.question ?? q.text,
                startupId: q.startupId ?? startupId,
                status: q.status ?? "open",
                text: q.text,
                visibility: q.visibility,
                createdAt: createdAtString,
                answer: q.answer
                    ? {
                        text: q.answer.text,
                        answeredByUid: q.answer.answeredByUid,
                        answeredAt: q.answer.answeredAt instanceof Timestamp
                            ? q.answer.answeredAt.toDate().toISOString()
                            : null,
                    }
                    : undefined,
            };
        });

        return {
            count: data.length,
            startupId,
            data,
        };
    }
);
