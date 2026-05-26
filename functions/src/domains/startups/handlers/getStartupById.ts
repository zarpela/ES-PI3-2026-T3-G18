// Desenvolvido por Abdallah
// Revisado com base na implementacao de Miguel Castro
// Abdallah El-Khatib

import {Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {getStartupById as fetchStartupById} from "../repositories/startupRepository";
import {normalizeString} from "../shared/validation";

type GetStartupByIdRequest = {
  id?: string;
  startupId?: string;
};

function serializeDate(value: unknown): string | null {
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  if (
    value &&
    typeof value === "object" &&
    "toDate" in value &&
    typeof (value as {toDate: () => Date}).toDate === "function"
  ) {
    return (value as {toDate: () => Date}).toDate().toISOString();
  }

  return null;
}

function serializeStartup(id: string, startup: Record<string, unknown>) {
  return {
    id,
    ...startup,
    createdAt: serializeDate(startup.createdAt),
  };
}

export const getStartupById = onCall(
  {region: "southamerica-east1"},
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
      data: serializeStartup(
        startupId,
        startup as unknown as Record<string, unknown>,
      ),
    };
  },
);

