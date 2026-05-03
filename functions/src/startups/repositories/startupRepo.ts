// Desenvolvido por Miguel Castro

import { HttpsError } from "firebase-functions/v2/https";
import { db } from "../shared/firebase";
import { StartupCatalog, StartupDoc, StartupQuestionDocument } from "../types";

const startupCol = db.collection("startups");

// ---------------------------------------------------------------------------
// Helpers internos
// ---------------------------------------------------------------------------

function questionsCol(startupId: string) {
    return startupCol.doc(startupId).collection("questions");
}

function investorsCol(startupId: string) {
    return startupCol.doc(startupId).collection("investors");
}

// Transforma o doc completo na versão resumida para o catálogo
function toCatalog(id: string, startup: StartupDoc): StartupCatalog {
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

// ---------------------------------------------------------------------------
// Startups
// ---------------------------------------------------------------------------

export async function getStartupsCatalogs(): Promise<StartupCatalog[]> {
    try {
        const snapshot = await startupCol.get();
        return snapshot.docs.map((doc) => toCatalog(doc.id, doc.data() as StartupDoc));
    } catch (e) {
        throw new HttpsError("internal", "Erro ao buscar startups.");
    }
}

export async function getStartupDocById(id: string): Promise<StartupDoc | undefined> {
    try {
        const doc = await startupCol.doc(id).get();
        if (!doc.exists) return undefined;
        return doc.data() as StartupDoc;
    } catch (e) {
        throw new HttpsError("internal", "Erro ao buscar startup.");
    }
}

// Alias semântico usado pelos handlers de perguntas
export async function getStartupById(id: string): Promise<StartupDoc | undefined> {
    return getStartupDocById(id);
}

// ---------------------------------------------------------------------------
// Investors (subcoleção)
// ---------------------------------------------------------------------------

/**
 * Verifica se o usuário possui um documento na subcoleção investors da startup.
 */
export async function userIsInvestor(startupId: string, uid: string): Promise<boolean> {
    try {
        const doc = await investorsCol(startupId).doc(uid).get();
        return doc.exists;
    } catch (e) {
        throw new HttpsError("internal", "Erro ao verificar investidor.");
    }
}

// ---------------------------------------------------------------------------
// Questions (subcoleção)
// ---------------------------------------------------------------------------

/**
 * Persiste uma nova pergunta e retorna o ID gerado.
 */
export async function createQuestion(
    startupId: string,
    question: StartupQuestionDocument
): Promise<string> {
    try {
        const ref = await questionsCol(startupId).add(question);
        return ref.id;
    } catch (e) {
        throw new HttpsError("internal", "Erro ao criar pergunta.");
    }
}

/**
 * Retorna apenas as perguntas públicas de uma startup, ordenadas por data.
 */
export async function getPublicQuestions(startupId: string): Promise<
    { id: string; data: StartupQuestionDocument }[]
> {
    try {
        const snapshot = await questionsCol(startupId)
            .where("visibility", "==", "publica")
            .orderBy("createdAt", "asc")
            .get();

        return snapshot.docs.map((doc) => ({
            id: doc.id,
            data: doc.data() as StartupQuestionDocument,
        }));
    } catch (e) {
        throw new HttpsError("internal", "Erro ao buscar perguntas.");
    }
}