import type {UserRecord} from "firebase-admin/auth";
import {auth} from "../../../shared/firebase";
import {normalizeEmail} from "../../../shared/utils";

export async function findUserByEmail(email: string): Promise<UserRecord | null> {
  try {
    return await auth.getUserByEmail(normalizeEmail(email));
  } catch (error) {
    const code = (error as {code?: string}).code;

    if (code === "auth/user-not-found" || code === "auth/invalid-email") {
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
