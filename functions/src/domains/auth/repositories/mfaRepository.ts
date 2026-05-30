//feito por Abdallah
import {db} from "../../../shared/firebase";
import type {StoredMfaCode} from "../../../shared/types";

const usersCollection = "users";
const mfaCodesCollection = "mfaLoginCodes";

export async function readUserMfaEnabled(uid: string): Promise<boolean> {
  // O status do MFA fica no perfil do usuario em /users/{uid}.
  const snapshot = await db.collection(usersCollection).doc(uid).get();

  if (!snapshot.exists) {
    return false;
  }

  return snapshot.data()?.mfaEnabled === true;
}

export async function setUserMfaEnabled(
  uid: string,
  enabled: boolean,
): Promise<void> {
  await db
    .collection(usersCollection)
    .doc(uid)
    .set(
      {
        mfaEnabled: enabled,
        mfaUpdatedAt: new Date().toISOString(),
      },
      {merge: true},
    );
}

export async function readMfaCode(uid: string): Promise<StoredMfaCode | null> {
  // O codigo do MFA fica separado em /mfaLoginCodes/{uid} para ser facilmente
  // invalidado (delete) apos uso/expiracao.
  const snapshot = await db.collection(mfaCodesCollection).doc(uid).get();

  if (!snapshot.exists) {
    return null;
  }

  return snapshot.data() as StoredMfaCode;
}

export async function storeMfaCode(record: StoredMfaCode): Promise<void> {
  await db
    .collection(mfaCodesCollection)
    .doc(record.uid)
    .set({
      ...record,
      updatedAt: new Date().toISOString(),
    });
}

export async function clearMfaCode(uid: string): Promise<void> {
  await db.collection(mfaCodesCollection).doc(uid).delete();
}
