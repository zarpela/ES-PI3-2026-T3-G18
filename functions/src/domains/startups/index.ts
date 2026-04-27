import {onRequest} from "firebase-functions/v2/https";
import {getStartupsHandler} from "./handlers/getStartupsHandler";

export const getStartups = onRequest(
  {region: "southamerica-east1"},
  getStartupsHandler,
);
