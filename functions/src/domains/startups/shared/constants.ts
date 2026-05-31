// Desenvolvido por Gabriel Scolfaro de Azeredo - RA: 25006194
// E ???


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