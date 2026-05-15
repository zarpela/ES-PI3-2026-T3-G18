import * as logger from "firebase-functions/logger";
import {onRequest} from "firebase-functions/v2/https";
import {getStartupsData} from "../services/getStartupsService";

type StartupRequestHandler = Parameters<typeof onRequest>[0];

export const getStartupsHandler: StartupRequestHandler = async (
  _request,
  response,
): Promise<void> => {
  try {
    const data = await getStartupsData();
    response.status(200).json(data);
  } catch (error) {
    logger.error("getStartups failed:", error);
    response.status(500).json({error: "Erro"});
  }
};
