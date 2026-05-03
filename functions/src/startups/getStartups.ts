// Feito por Miguel Castro

import {onRequest} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2/options";
import {db} from "../config/firebase";

setGlobalOptions({region: "southamerica-east1"});

const colStartUps = db.collection("startups");

export const getStartups = onRequest(async (_request, response) => {
  try {
    const snapshot = await colStartUps.get();

    const data = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    response.status(200).json(data);
  } catch (error) {
    console.error("getStartups failed:", error);
    response.status(500).json({error: "Erro"});
  }
});
