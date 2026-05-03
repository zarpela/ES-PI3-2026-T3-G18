// Desenvolvido por Miguel Castro

import { HttpsError, onCall } from "firebase-functions/https";
import { getStartupDocById } from "../repositories/startupRepo";

export const getStartupById = onCall (
    { region: "southamerica-east1" }, 
    async (request) => {

    const id = request.data?.id;

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