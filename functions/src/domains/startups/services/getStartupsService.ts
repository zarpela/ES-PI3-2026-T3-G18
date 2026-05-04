import {fetchAllStartups} from "../repositories/startupRepository";

export async function getStartupsData(): Promise<Array<Record<string, unknown>>> {
  return fetchAllStartups();
}
