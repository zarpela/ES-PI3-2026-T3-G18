import type {Request, Response} from "express";
import * as logger from "firebase-functions/logger";
import {runFirestoreTest} from "../services/testFirestoreService";

export async function testFirestoreHandler(
  _req: Request,
  res: Response,
): Promise<void> {
  try {
    await runFirestoreTest();
    res.json({ok: true, message: "Salvou no Firestore!"});
  } catch (error) {
    logger.error("Erro ao salvar documento de teste no Firestore.", error);
    res.status(500).json({ok: false, error: "Erro ao salvar"});
  }
}
