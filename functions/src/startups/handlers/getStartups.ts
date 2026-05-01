// Desenvolvido por Miguel Castro

import { HttpsError, onCall } from "firebase-functions/https";
import { getStartupsCatalogs } from "../repositories/startupRepo";
import { StartupStage } from "../types";
import { allowedStages } from "../shared/constants";

/**
 * Padronização do request
 */
type GetStartupsRequest = {
  stage?: StartupStage;
  sector?: string;
}

export const getStartups = onCall(async (request) => {

  // filtros
  const data = request.data as GetStartupsRequest;

  const stage = data.stage;
  const sector = data.sector;

  if(stage && !allowedStages.includes(stage)){
    throw new HttpsError(
      "invalid-argument",
      "Filtro de estágio inválido"
    );
  }

  const startups = (await getStartupsCatalogs())
  .filter((startup) => !stage || startup.stage === stage)
  .filter((startup) => !sector || startup.sector === sector)
  .sort((left, right) => left.name.localeCompare(right.name, "pt-BR"));

  return {
    count: startups.length,
    filters: {stage: stage ?? null,
              sector: sector ?? null},
    data: startups,
  }

})
