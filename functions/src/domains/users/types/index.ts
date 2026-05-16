// Desenvolvido por Miguel Castro
import { Timestamp } from "firebase-admin/firestore";

/**
 * Carteira do usuário
 */
export type Wallet = {
    balance: number, // saldo

    // não é nulo pq é adicionado um timestamp na criação da carteira
    createdAt: Timestamp,
    lastUpdated: Timestamp,
}