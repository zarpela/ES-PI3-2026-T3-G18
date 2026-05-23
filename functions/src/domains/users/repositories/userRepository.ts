// Desenvolvido por ???
//                e Miguel Castro

import type {UserRecord} from "firebase-admin/auth";
import {FieldValue} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/https";
import {auth, db} from "../../../shared/firebase";
import {Wallet} from "../types";

const walletCol = db.collection("wallet");

type CreateAuthUserPayload = {
  displayName: string;
  email: string;
  password: string;
};

type UserProfilePayload = {
  cpf: string;
  createdAt: Date;
  email: string;
  mfaEnabled?: boolean;
  nome: string;
  telefone: string;
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
 * e chamado junto com a criacao do usuario
 * para criar uma carteira associada a ele
 */
export async function createWallet(uid: string): Promise<Wallet> {
  try {
    const wallet: Wallet = {
      userId: uid,
      balance: 0,
      totalInvested: 0,
      totalCurrentValue: 0,
      totalProfitLoss: 0,
      totalProfitLossPercent: 0,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };

    // Miguel iniciou esta criacao automatica
    // Abdallah ajustou o documento para a colecao wallet
    await walletCol.doc(uid).set(wallet, {merge: true});
    return wallet;
  } catch (e) {
    console.error(e);

    throw new HttpsError(
      "internal",
      "Erro ao criar carteira.",
    );
  }
}
