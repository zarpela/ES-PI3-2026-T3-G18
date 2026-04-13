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
        // a coleção já foi definida lá em cima
        const snapshot = await colStartUps.get(); 

        // organiza as informações em um map
        const data = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }))

        // devolve os dados
        response.status(200).json(data)
    }
    catch (e) {
        console.error("getStartups failed:", e); // apresenta o erro especificamente
        response.status(500).json({error: "Erro"});
    }
});
