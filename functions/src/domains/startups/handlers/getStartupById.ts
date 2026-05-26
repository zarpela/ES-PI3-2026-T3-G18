<<<<<<< Updated upstream
// Desenvolvido por Abdallah

import { Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { getStartupById as fetchStartupById } from "../repositories/startupRepository";
import { normalizeString } from "../shared/validation";

type GetStartupByIdRequest = {
  id?: string;
  startupId?: string;
};

function serializeStartup(id: string, startup: Record<string, unknown>) {
  const createdAt = startup.createdAt;

  return {
    id,
    ...startup,
    createdAt: createdAt instanceof Timestamp ? createdAt.toDate().toISOString() : null,
  };
}

export const getStartupById = onCall(
  { region: "southamerica-east1" },
  async (request) => {
    const data = (request.data ?? {}) as Partial<GetStartupByIdRequest>;
    const startupId = normalizeString(data.id ?? data.startupId);

    if (!startupId) {
      throw new HttpsError("invalid-argument", "Informe o id da startup.");
    }

    const startup = await fetchStartupById(startupId);

    if (!startup) {
      throw new HttpsError("not-found", "Startup nao encontrada.");
    }

    return {
      startupId,
      data: serializeStartup(startupId, startup as unknown as Record<string, unknown>),
    };
  },
);
=======
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
>>>>>>> Stashed changes
