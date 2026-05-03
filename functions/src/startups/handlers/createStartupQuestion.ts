// Desenvolvido por Gabriel Scolfaro

import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { allowedVisibilities } from "../shared/constants";
import { requireAuthenticatedUser } from "../shared/auth";
import { normalizeString } from "../shared/validation";
import {
    createQuestion,
    getStartupById,
    userIsInvestor,
} from "../repositories/startupRepo";
import { QuestionVisibility, StartupQuestionDocument } from "../types";

/**
 * Cria uma pergunta para uma startup.
 *
 * Parâmetros esperados no request.data:
 *   - startupId: identificador da startup
 *   - text: texto da pergunta
 *   - visibility: "publica" (padrão) ou "privada"
 *
 * Perguntas públicas podem ser enviadas por qualquer usuário autenticado.
 * Perguntas privadas exigem que o usuário possua um documento em:
 *   startups/{startupId}/investors/{uid}
 */
export const createStartupQuestion = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const user = requireAuthenticatedUser(request);

        const startupId = normalizeString(request.data?.startupId);
        const text = normalizeString(request.data?.text);
        const visibility = (normalizeString(request.data?.visibility) ?? "publica") as QuestionVisibility;

        if (!startupId || !text) {

            throw new HttpsError(
                "invalid-argument",
                "Informe startupId e text."
            );
        }

        if (!allowedVisibilities.includes(visibility)) {
            throw new HttpsError(
                "invalid-argument",
                "Visibility inválida. Use 'publica' ou 'privada'."
            );
        }

        const startup = await getStartupById(startupId);

        if (!startup) {
            throw new HttpsError("not-found", "Startup não encontrada.");
        }

        if (visibility === "privada") {
            const isInvestor = await userIsInvestor(startupId, user.uid);

            if (!isInvestor) {
                throw new HttpsError(
                    "permission-denied",
                    "Apenas investidores desta startup podem enviar perguntas privadas."
                );
            }
        }

        const question: StartupQuestionDocument = {
            authorUid: user.uid,
            authorEmail: user.email,
            text,
            visibility,
            createdAt: FieldValue.serverTimestamp(),
        };

        const questionId = await createQuestion(startupId, question);

        logger.info("Pergunta criada para startup.", {
            startupId,
            questionId,
            visibility,
        });

        return {
            data: {
                id: questionId,
                startupId,
                visibility,
            },
        };
    }
);