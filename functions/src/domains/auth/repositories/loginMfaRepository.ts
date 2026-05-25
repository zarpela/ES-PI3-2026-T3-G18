import {db} from "../../../shared/firebase";
import type {StoredLoginMfaCode} from "../../../shared/types";

const loginMfaCodesCollection = "loginMfaCodes";

export async function readLoginMfaCode(
  uid: string,
): Promise<StoredLoginMfaCode | null> {
  const snapshot = await db.collection(loginMfaCodesCollection).doc(uid).get();

  if (!snapshot.exists) {
    return null;
  }

  return snapshot.data() as StoredLoginMfaCode;
}

export async function storeLoginMfaCode(
  record: StoredLoginMfaCode,
): Promise<void> {
  await db.collection(loginMfaCodesCollection).doc(record.uid).set({
    ...record,
    updatedAt: new Date().toISOString(),
  });
}

export async function clearLoginMfaCode(uid: string): Promise<void> {
  await db.collection(loginMfaCodesCollection).doc(uid).delete();
}
