import admin from "firebase-admin";
import fs from "fs";
import path from "path";

function initializeFirebaseApp(): admin.app.App {
  if (admin.apps.length > 0) {
    return admin.app();
  }

  const serviceAccountPath = path.resolve(__dirname, "../../serviceAccount.json");

  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = JSON.parse(
      fs.readFileSync(serviceAccountPath, "utf8"),
    ) as admin.ServiceAccount;

    return admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }

  return admin.initializeApp();
}

const firebaseApp = initializeFirebaseApp();

export const db = admin.firestore(firebaseApp);
export const auth = admin.auth(firebaseApp);
