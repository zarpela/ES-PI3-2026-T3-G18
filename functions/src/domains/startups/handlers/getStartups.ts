// Desenvolvido por Miguel Afonso Castro de Almeida - RA: 25016044

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getStartupsCatalogs } from "../repositories/startupRepository";
import { StartupStage } from "../types";
import { allowedStages } from "../shared/constants";

/**
 * Padronização do request
 */
type GetStartupsRequest = {
  stage?: StartupStage;
  sector?: string;
}

export const getStartups = onCall(
  { region: "southamerica-east1" },
  async (request) => {

  
  // Caso a request seja undefined de alguma forma, 
  // não quebra as variaveis stage e sector
  const data = (request.data ?? {}) as Partial<GetStartupsRequest>;

  // filtros
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
