import {db} from "../../../shared/firebase";
import type {StoredResetCode} from "../../../shared/types";
import {normalizeEmail} from "../../../shared/utils";

const passwordResetCodesCollection = "passwordResetCodes";

export async function readResetCode(
  email: string,
): Promise<StoredResetCode | null> {
  const snapshot = await db
    .collection(passwordResetCodesCollection)
    .doc(normalizeEmail(email))
    .get();

  if (!snapshot.exists) {
    return null;
  }

  return snapshot.data() as StoredResetCode;
}

export async function storeResetCode(record: StoredResetCode): Promise<void> {
  await db
    .collection(passwordResetCodesCollection)
    .doc(record.email)
    .set({
      ...record,
      updatedAt: new Date().toISOString(),
    });
}

export async function clearResetCode(email: string): Promise<void> {
  await db
    .collection(passwordResetCodesCollection)
    .doc(normalizeEmail(email))
    .delete();
}
