// Desenvolvido por Gabriel Scolfaro de Azeredo - RA: 25006194

import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { AuthenticatedUser } from "../types";

export function requireAuthenticatedUser(
    request: CallableRequest
): AuthenticatedUser {
    if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "O usuário precisa estar autenticado para acessar esta função."
        );
    }

    return {
        uid: request.auth.uid,
        email: request.auth.token.email as string | undefined,
    };
}