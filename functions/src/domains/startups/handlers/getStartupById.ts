// Desenvolvido por Miguel Castro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getStartupDocById } from "../repositories/startupRepository";
import { normalizeString } from "../shared/validation";

export const getStartupById = onCall (
    { region: "southamerica-east1" }, 
    async (request) => {

    // tratamento de dados não-vazios, mas ainda inválidos
    const id = normalizeString(request.data?.id);

    if(!id) {
        throw new HttpsError(
            "invalid-argument",
            "Informe o id para busca"
        )
    }
    const startup = await getStartupDocById(id);

    if (!startup) {
        throw new HttpsError("not-found", "Startup nao encontrada.");
    }

    return {
        data: {
            id: id,
            ...startup,
            createdAt: startup.createdAt?.toDate().toISOString() ?? null,
        }
    };

})