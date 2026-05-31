// Desenvolvido por Miguel Afonso Castro de Almeida - RA: 25016044
import {FieldValue, Timestamp} from "firebase-admin/firestore";

/**
 * Carteira do usuario
 */
export type Wallet = {
    userId: string;
    balance: number; // saldo
    totalInvested: number;
    totalCurrentValue: number;
    totalProfitLoss: number;
    totalProfitLossPercent: number;

    // Miguel Afonso Castro de Almeida - RA: 25016044 iniciou esta tipagem
    // Abdallah Ali Borges El-Khatib - RA: 25018711 ajustou a estrutura para wallet/{userId}
    createdAt: Timestamp | FieldValue;
    updatedAt: Timestamp | FieldValue;
};
