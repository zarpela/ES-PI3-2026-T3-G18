// Desenvolvido por Miguel Afonso Castro de Almeida - RA: 25016044

import { onSchedule } from "firebase-functions/v2/scheduler";
import { saveAllPriceSnapshots } from "../repositories/startupRepository";

export const saveHistory = onSchedule(
  {
    schedule: "0 */4 * * *",
    timeZone: "America/Sao_Paulo",
  },
  async () => {
    await saveAllPriceSnapshots();
  }
);