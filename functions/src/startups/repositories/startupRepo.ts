// Desenvolvido por Miguel Castro

import { HttpsError } from "firebase-functions/https";
import {db} from "../shared/firebase";
import {StartupCatalog,StartupDoc} from "../types";


const startupCol = db.collection("startups");

// Transforma todo o doc (o bd puxa tudo) na versão resumida
function  toCatalog(id: string, startup: StartupDoc): StartupCatalog {
    return {
        id,
        name: startup.name,
        description: startup.description, // descricão simples
        stage: startup.stage,
        sector: startup.sector,
        
        // apresentação visual
        backgroundImage: startup.backgroundImage, // URL
        logo: startup.logo, // URL
        
        // dados para possiveis cálculos
        totalEmittedTokens: startup.totalEmittedTokens,
        raisedCapital: startup.raisedCapital, // capital aportado
        targetCapital: startup.targetCapital, // meta de captação
    }
}

// Cria uma lista com todos os resultados encontrados
export async function getStartupsCatalogs(): Promise<StartupCatalog[]> {
    try {
        const snapshot = await startupCol.get();

        return snapshot.docs.map((doc) => toCatalog(doc.id, doc.data() as StartupDoc))
    } catch (e) {
        throw new HttpsError(
            "internal",
            "Erro ao buscar startups"
        );
    }
    
}

// Busca uma startup
export async function getStartupDocById(Id: string): Promise<StartupDoc | undefined> {
    try {
        const startup = await startupCol.doc(Id).get();

        if(!startup.exists) {
            return undefined;
        }

        return startup.data() as StartupDoc;

    } catch (e) {
        throw new HttpsError(
            "internal",
            "Erro ao buscar startup"
        );
    }
    
}