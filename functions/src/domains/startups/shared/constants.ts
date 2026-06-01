// Desenvolvido por Gabriel Scolfaro de Azeredo - RA: 25006194
//feito por Abdallah Ali Borges El-Khatib - RA: 25018711


import { StartupStage, QuestionVisibility } from "../types";

export const allowedStages: StartupStage[] = [
    "nova",
    "em_operacao",
    "em_expansao",
];

export const allowedVisibilities: QuestionVisibility[] = [
    "publica",
    "privada",
];
