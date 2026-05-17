// Desenvolvido por Miguel Castro

import { Timestamp } from "firebase-admin/firestore";

/**
 * Token
 */
export type Token = {
    amount: number,
    averagePrice: number, // útil para calcular valorização
    lastUpdated?: Timestamp;
}

// poderia ser possível cancelar uma venda
export type SellOrderStatus = "open" | "completed" | "cancelled";

/**
 * Ordem de venda
 */
export type SellOrder = {
    // identificação
    id?: string;
    ownerId: string,
    startupId: string,

    // visual
    startupName: string,

    // dados da ordem
    amount: number,
    pricePerToken: number,
    averagePrice: number,

    // dados para controle
    createdAt: Timestamp,
    status: SellOrderStatus,

}