// Desenvolvido por Miguel Castro

import { HttpsError } from "firebase-functions/v2/https";
import { db } from "../../../shared/firebase";
import {
    StartupCatalog,
    StartupDoc,
    StartupQuestionDocument,
} from "../types";

// ---------------------------------------------------------------------------
// Collections
// ---------------------------------------------------------------------------

const startupCol = db.collection("startups");

function startupDoc(startupId: string) {
    return startupCol.doc(startupId);
}

function questionsCol(startupId: string) {
    return startupDoc(startupId).collection("questions");
}

function investorsCol(startupId: string) {
    return startupDoc(startupId).collection("investors");
}

// ---------------------------------------------------------------------------
// Mappers
// ---------------------------------------------------------------------------

function toCatalog(id: string, startup: StartupDoc): StartupCatalog {
    return {
        id,
        name: startup.name,
        description: startup.description,
        stage: startup.stage,
        sector: startup.sector,

        backgroundImage: startup.backgroundImage,
        logo: startup.logo,

        totalEmittedTokens: startup.totalEmittedTokens,
        raisedCapital: startup.raisedCapital,
        targetCapital: startup.targetCapital,
    };
}

// ---------------------------------------------------------------------------
// Startups
// ---------------------------------------------------------------------------

/**
 * Retorna todas as startups completas
 */
export async function fetchAllStartups(): Promise<
    Array<StartupDoc & { id: string }>
> {
    try {
        const snapshot = await startupCol.get();

        return snapshot.docs.map((doc) => ({
            id: doc.id,
            ...(doc.data() as StartupDoc),
        }));
    } catch (e) {
        throw new HttpsError("internal", "Erro ao buscar startups.");
    }
}

/**
 * Retorna catálogo resumido
 */
export async function getStartupsCatalogs(): Promise<StartupCatalog[]> {
    try {
        const snapshot = await startupCol.get();

        return snapshot.docs.map((doc) =>
            toCatalog(doc.id, doc.data() as StartupDoc)
        );
    } catch (e) {
        throw new HttpsError("internal", "Erro ao buscar startups.");
    }
}

/**
 * Busca startup por ID
 */
export async function getStartupDocById(
    id: string
): Promise<StartupDoc | undefined> {
    try {
        const doc = await startupDoc(id).get();

        if (!doc.exists) return undefined;

        return doc.data() as StartupDoc;
    } catch (e) {
        throw new HttpsError("internal", "Erro ao buscar startup.");
    }
}

// Alias semântico
export async function getStartupById(
    id: string
): Promise<StartupDoc | undefined> {
    return getStartupDocById(id);
}

// ---------------------------------------------------------------------------
// Investors
// ---------------------------------------------------------------------------

export async function userIsInvestor(
    startupId: string,
    uid: string
): Promise<boolean> {
    try {
        const doc = await investorsCol(startupId).doc(uid).get();

        return doc.exists;
    } catch (e) {
        throw new HttpsError("internal", "Erro ao verificar investidor.");
    }
}

// ---------------------------------------------------------------------------
// Questions
// ---------------------------------------------------------------------------

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

export async function getPublicQuestions(
    startupId: string
): Promise<
    {
        id: string;
        data: StartupQuestionDocument;
    }[]
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