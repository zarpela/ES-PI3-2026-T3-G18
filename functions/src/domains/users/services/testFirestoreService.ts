import {saveTestDocument} from "../repositories/userRepository";

export async function runFirestoreTest(): Promise<void> {
  await saveTestDocument();
}
