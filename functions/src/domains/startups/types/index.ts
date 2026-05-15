// Desenvolvido por Miguel Castro

import { Timestamp, FieldValue } from "firebase-admin/firestore";

/**
 * Sócios de uma startup
 */
export type Shareholder = {
    name: string;
    equityInterest: number; // participação societária
    role: string;
    description: string;
}

/**
 * Estágios da startup
 */
export type StartupStage = "nova" | "em_operacao" | "em_expansao";

/**
 * Membro externo
 */
export type ExternalMember = {
    name: string;
    role: string; // exemplo: mentor
}

/**
 * Documento com todas as informações da Startup
 */
export type StartupDoc = {
    name: string;
    description: string; // descricão simples
    executiveSummary: string;
    stage: StartupStage;
    sector: string;
    shareholders: Shareholder[];
    externalMembers: ExternalMember[];

    // apresentação visual
    backgroundImage: string; // URL
    logo: string; // URL
    video: string; // URL

    // dados para possíveis cálculos
    totalEmittedTokens: number;
    raisedCapital: number; // capital aportado
    targetCapital: number; // meta de captação
    createdAt?: Timestamp;
}

/**
 * Versão resumida de Doc para apresentação no catálogo
 */
export type StartupCatalog = {
    id: string;
    name: string;
    description: string; // descricão simples
    stage: StartupStage;
    sector: string;

    // apresentação visual
    backgroundImage: string; // URL
    logo: string; // URL

    // dados para possíveis cálculos
    totalEmittedTokens: number;
    raisedCapital: number; // capital aportado
    targetCapital: number; // meta de captação
}

/**
 * Usuário autenticado extraído do request
 */
export type AuthenticatedUser = {
    uid: string;
    email: string | undefined;
}

/**
 * Visibilidade de uma pergunta
 */
export type QuestionVisibility = "publica" | "privada";

/**
 * Resposta de uma pergunta
 */
export type QuestionAnswer = {
    text: string;
    answeredByUid: string;
    answeredByEmail: string | undefined;
    answeredAt: Timestamp | FieldValue;
}

/**
 * Documento de uma pergunta armazenado no Firestore
 * Subcoleção: startups/{startupId}/questions/{questionId}
 */
export type StartupQuestionDocument = {
    authorUid: string;
    authorEmail: string | undefined;
    text: string;
    visibility: QuestionVisibility;
    createdAt: Timestamp | FieldValue;
    answer?: QuestionAnswer;
}

/**
 * Versão serializada para retorno na API
 */
export type StartupQuestionResponse = {
    id: string;
    authorUid: string;
    authorEmail: string | undefined;
    text: string;
    visibility: QuestionVisibility;
    createdAt: string | null;
    answer?: {
        text: string;
        answeredByUid: string;
        answeredByEmail: string | undefined;
        answeredAt: string | null;
    };
}