// Desenvolvido por Miguel Afonso Castro de Almeida - RA: 25016044

import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

if (getApps().length === 0) {
    initializeApp();
}

export const db = getFirestore();