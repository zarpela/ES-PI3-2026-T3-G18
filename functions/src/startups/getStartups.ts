// Feito por Miguel Castro
// Function separada para listar startups no Firestore.
// Agora também responde com CORS para funcionar no Flutter Web.
import {onRequest} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2/options";
import { db } from "../config/firebase";
import cors from "cors";

setGlobalOptions({region: "southamerica-east1"});

const colStartUps = db.collection("startups");
const corsHandler = cors({origin: true});

export const getStartups = onRequest((request, response) => {
  corsHandler(request, response, async () => {
    try {
      const snapshot = await colStartUps.get();

      const data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      response.status(200).json(data);
    } catch (e) {
      console.error("getStartups failed:", e);
      response.status(500).json({error: "Erro"});
    }
  });
});