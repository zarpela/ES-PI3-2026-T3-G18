// Desenvolvido por Gabriel Scolfaro de Azeredo - RA: 25006194
//feito por Abdallah Ali Borges El-Khatib - RA: 25018711

import admin from "firebase-admin";
import fs from "fs";
import { resolveFunctionsPath } from "./utils";

function initializeFirebaseApp(): admin.app.App {
  if (admin.apps.length > 0) {
    return admin.app();
  }

  const serviceAccountPath = resolveFunctionsPath("serviceAccount.json");

  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = JSON.parse(
      fs.readFileSync(serviceAccountPath, "utf8"),
    ) as admin.ServiceAccount;

    return admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: "projetointegrador3-grupo18.firebasestorage.app",
    });
  }

  return admin.initializeApp();
}

const firebaseApp = initializeFirebaseApp();

export { firebaseApp };
export const db = admin.firestore(firebaseApp);
export const auth = admin.auth(firebaseApp);
export const storage = admin.storage(firebaseApp);
