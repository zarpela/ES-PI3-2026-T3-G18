import type {UserRecord} from "firebase-admin/auth";
import {auth} from "../../../shared/firebase";
import {normalizeEmail} from "../../../shared/utils";

export async function findUserByEmail(email: string): Promise<UserRecord | null> {
  try {
    return await auth.getUserByEmail(normalizeEmail(email));
  } catch (error) {
    if ((error as {code?: string}).code === "auth/user-not-found") {
      return null;
    }

    throw error;
  }
}

export async function updateUserPassword(
  uid: string,
  password: string,
): Promise<void> {
  await auth.updateUser(uid, {password});
}
