// Feito por Miguel Castro

import { onRequest } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2/options";
import * as admin from "firebase-admin";

admin.initializeApp();

setGlobalOptions({ region: "southamerica-east1" });

const db = admin.firestore();
const colStartUps = db.collection("startups");

export const getStartups = onRequest(async (request, response) => {
    try {
        const snapshot = await colStartUps.get(); 

        // a coleção já foi definida lá em cima
        const data = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }))

        // devolve os dados
        response.status(200).json(data)
    }
    catch (e) {
        response.status(500).json({error: "Erro"});
    }
});
