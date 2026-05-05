import type {UserRecord} from "firebase-admin/auth";
import {auth, db} from "../../../shared/firebase";

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
