// Desenvolvido por Miguel Castro

import { getAuth } from "firebase-admin/auth";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

if (getApps().length === 0) {
    initializeApp();
}

export const auth = getAuth();
export const db = getFirestore();