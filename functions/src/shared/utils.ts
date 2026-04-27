import * as logger from "firebase-functions/logger";
import fs from "fs";
import path from "path";

const functionsRootPath = path.resolve(__dirname, "..", "..");

export function resolveFunctionsPath(...segments: string[]): string {
  return path.resolve(functionsRootPath, ...segments);
}

export function loadJsonFile<T>(filePath: string): T | undefined {
  if (!fs.existsSync(filePath)) {
    return undefined;
  }

  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8")) as T;
  } catch (error) {
    logger.error(`Nao foi possivel ler ${path.basename(filePath)}.`, error);
    return undefined;
  }
}

export function normalizeEmail(value: string): string {
  return value.trim().toLowerCase();
}

export function generateVerificationCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

export function shouldReturnCodeForTesting(): boolean {
  return process.env.FUNCTIONS_EMULATOR === "true";
}

export function isExpired(expiresAt: string): boolean {
  return new Date(expiresAt).getTime() < Date.now();
}

export function createFutureIsoString(minutesFromNow: number): string {
  return new Date(Date.now() + minutesFromNow * 60 * 1000).toISOString();
}
