// Desenvolvido por ???
//                e Miguel Castro

import type {UserRecord} from "firebase-admin/auth";
import {auth, db} from "../../../shared/firebase";
import { Wallet} from "../types";
import { Timestamp } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";


const walletCol = db.collection("wallets");

type CreateAuthUserPayload = {
  email: string;
  password: string;
  displayName: string;
};

type UserProfilePayload = {
  nome: string;
  cpf: string;
  telefone: string;
  email: string;
  createdAt: Date;
};

export async function createAuthUser(
  payload: CreateAuthUserPayload,
): Promise<UserRecord> {
  return auth.createUser(payload);
}

export async function saveUserProfile(
  uid: string,
  payload: UserProfilePayload,
): Promise<void> {
  await db.collection("users").doc(uid).set(payload);
}

export async function saveTestDocument(): Promise<void> {
  await db.collection("teste").add({
    ok: true,
    createdAt: new Date(),
  });
}

/**
 * é chamado junto com a criação do usuário 
 * para criar uma carteira associada a ele
 */
export async function createWallet(uid: string): Promise<Wallet> {
  try {
    const now = Timestamp.now();
    const wallet: Wallet = {
      balance: 0,
      createdAt: now,
      lastUpdated: now,
    };

    await walletCol.doc(uid).set(wallet);
    return wallet;
  } catch (e) {
  console.error(e);

  throw new HttpsError(
    "internal",
    "Erro ao criar carteira."
  );
}
}

