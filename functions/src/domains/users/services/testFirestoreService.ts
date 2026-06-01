// feito por Gabriel Scolfaro de Azeredo - RA: 25006194

import {saveTestDocument} from "../repositories/userRepository";

export async function runFirestoreTest(): Promise<void> {
  await saveTestDocument();
}
