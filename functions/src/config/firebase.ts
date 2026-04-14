import admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp({
    projectId: process.env.GCLOUD_PROJECT || process.env.FIREBASE_PROJECT || "demo-project",
  });
}

export const db = admin.firestore();
export const auth = admin.auth();