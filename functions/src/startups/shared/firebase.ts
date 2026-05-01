// Desenvolvido por Miguel Castro

import {getApps, initializeApp} from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

// evita múltiplas inicializações
if(getApps().length === 0){
    initializeApp(); // inicializa o sdk
}

export const db = getFirestore();