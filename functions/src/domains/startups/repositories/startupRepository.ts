// Desenvolvido por Miguel Castro
// e Gabriel Scolfaro de Azeredo
import { Timestamp } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import { db } from "../../../shared/firebase";
import {
    StartupCatalog,
    StartupDoc,
    StartupQuestionDocument,
    TokenPriceHistory,
} from "../types";
import * as admin from "firebase-admin"; // só pra schedule

// ---------------------------------------------------------------------------
// Collections
// ---------------------------------------------------------------------------

const startupCol = db.collection("startups");

function startupDoc(startupId: string) {
    return startupCol.doc(startupId);
}

function legacyQuestionsCol(startupId: string) {
    return startupDoc(startupId).collection("questions");
}

function publicQuestionsCol(startupId: string) {
    return startupDoc(startupId).collection("publicQuestions");
}

function privateQuestionsCol(startupId: string) {
    return startupDoc(startupId).collection("privateQuestions");
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
        console.error("Erro em fetchAllStartups:", e);
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
        console.error("Erro em getStartupsCatalogs:", e);
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
        console.error("Erro em getStartupDocById:", e);
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
        const [investorDoc, holdingDoc] = await Promise.all([
            investorsCol(startupId).doc(uid).get(),
            db.collection("wallets")
                .doc(uid)
                .collection("holdings")
                .doc(startupId)
                .get(),
        ]);

        if (investorDoc.exists) {
            return true;
        }

        if (!holdingDoc.exists) {
            return false;
        }

        const quantity = Number(holdingDoc.data()?.quantity ?? 0);

        return quantity > 0;
    } catch (e) {
        console.error("Erro em userIsInvestor:", e);
        throw new HttpsError("internal", "Erro ao verificar investidor.");
    }
}

//feito por Abdallah
export async function userCanReadAllPrivateQuestions(
    startupId: string,
    uid: string
): Promise<boolean> {
    try {
        const [userDoc, startup] = await Promise.all([
            db.collection("users").doc(uid).get(),
            startupDoc(startupId).get(),
        ]);
        const role = String(userDoc.data()?.role ?? "").toLowerCase();

        if (["admin", "responsavel", "owner", "startup_admin"].includes(role)) {
            return true;
        }

        const startupData = startup.data() ?? {};
        const responsibleId = String(
            startupData.responsibleUserId ??
            startupData.ownerId ??
            startupData.adminId ??
            ""
        );

        return responsibleId === uid;
    } catch (e) {
        console.error("Erro em userCanReadAllPrivateQuestions:", e);
        throw new HttpsError("internal", "Erro ao validar permissoes.");
    }
}

// ---------------------------------------------------------------------------
// Questions
// ---------------------------------------------------------------------------

//feito por Abdallah
export async function createQuestion(
    startupId: string,
    question: StartupQuestionDocument
): Promise<string> {
    try {
        const targetCollection = question.visibility === "privada" ?
            privateQuestionsCol(startupId) :
            publicQuestionsCol(startupId);
        const ref = await targetCollection.add(question);

        return ref.id;
    } catch (e) {
        console.error("Erro em createQuestion:", e);
        throw new HttpsError("internal", "Erro ao criar pergunta.");
    }
}

//feito por Abdallah
export async function getPublicQuestions(
    startupId: string
): Promise<
    {
        id: string;
        data: StartupQuestionDocument;
    }[]
> {
    try {
        const [publicSnapshot, legacySnapshot] = await Promise.all([
            publicQuestionsCol(startupId)
                .get(),
            legacyQuestionsCol(startupId)
                .where("visibility", "==", "publica")
                .get(), // Removido orderBy para evitar erro de Index no Firestore
        ]);

        const allDocs = [...publicSnapshot.docs, ...legacySnapshot.docs].map((doc) => ({
            id: doc.id,
            data: doc.data() as StartupQuestionDocument,
        }));

        // Ordenação em memória para não depender de índices complexos
        return allDocs.sort((a, b) => {
            const timeA = a.data.createdAt instanceof Timestamp ? a.data.createdAt.toMillis() : 0;
            const timeB = b.data.createdAt instanceof Timestamp ? b.data.createdAt.toMillis() : 0;
            return timeA - timeB;
        });

    } catch (e) {
        console.error("Erro em getPublicQuestions:", e);
        throw new HttpsError("internal", "Erro ao buscar perguntas.");
    }
}

//feito por Abdallah
export async function getPrivateQuestions(
    startupId: string,
    uid: string,
    canReadAll = false
): Promise<{ id: string; data: StartupQuestionDocument }[]> {
    try {
        const [privateSnapshot, legacySnapshot] = await Promise.all([
            privateQuestionsCol(startupId)
                .get(),
            legacyQuestionsCol(startupId)
                .where("visibility", "==", "privada")
                .get(), // Removido orderBy para evitar erro de Index no Firestore
        ]);

        let docs = [...privateSnapshot.docs, ...legacySnapshot.docs]
            .map((doc) => ({
                id: doc.id,
                data: doc.data() as StartupQuestionDocument,
            }))
            .filter(({ data }) => {
                if (canReadAll) {
                    return true;
                }
                return data.authorId === uid || data.authorUid === uid;
            });

        // Ordenação em memória para não depender de índices complexos
        return docs.sort((a, b) => {
            const timeA = a.data.createdAt instanceof Timestamp ? a.data.createdAt.toMillis() : 0;
            const timeB = b.data.createdAt instanceof Timestamp ? b.data.createdAt.toMillis() : 0;
            return timeA - timeB;
        });

    } catch (e) {
        console.error("Erro em getPrivateQuestions:", e);
        throw new HttpsError("internal", "Erro ao buscar perguntas privadas.");
    }
}

/**
 * Salva o histórico ed valorização do token
 * vai ser chamado em /schedule a cada 4h, começando 00:00
 */
export async function saveAllPriceSnapshots() {
    try {
        const snapshot = await db.collection("startups").get();

        const promises = snapshot.docs.map(async (startupDoc) => {
            const startup = startupDoc.data() as StartupDoc;
            const history: TokenPriceHistory = {
                price: startup.tokenPrice,
                createdAt: admin.firestore.Timestamp.now(),
            };

            return db
                .collection("startups")
                .doc(startupDoc.id)
                .collection("tokenPriceHistory")
                .add(history);
        });

        await Promise.all(promises);
    } catch(e) {
        console.error("Erro em saveAllPriceSnapshots:", e);
    }
}

//feito por Abdallah
export async function getTokenPriceHistory(
    startupId: string,
    startDate: Date
): Promise<TokenPriceHistory[]> {
    try {
        const snapshot = await startupDoc(startupId)
            .collection("tokenPriceHistory")
            .where("createdAt", ">=", Timestamp.fromDate(startDate))
            .orderBy("createdAt", "asc")
            .get();

        return snapshot.docs.map((doc) => doc.data() as TokenPriceHistory);
    } catch (e) {
        console.error("Erro em getTokenPriceHistory:", e);
        throw new HttpsError("internal", "Erro ao buscar histórico de preços.");
    }
}
