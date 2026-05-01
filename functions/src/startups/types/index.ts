// Desenvolvido por Miguel Castro

import {Timestamp} from "firebase-admin/firestore";

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
    role: string; // exemplo : mentor
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

    // dados para possiveis cálculos
    totalEmittedTokens: number;
    raisedCapital: number; // capital aportado
    targetCapital: number; // meta de captação
    createdAt?: Timestamp;
}

/**
 * Versão resumida de Doc para apresentação no catalogo
 */
export type StartupCatalog = {
    id: string,
    name: string;
    description: string; // descricão simples
    stage: StartupStage;
    sector: string;

    // apresentação visual
    backgroundImage: string; // URL
    logo: string; // URL

    // dados para possiveis cálculos
    totalEmittedTokens: number;
    raisedCapital: number; // capital aportado
    targetCapital: number; // meta de captação
}



// Falta implementar Perguntas