// Desenvolvido por Miguel Castro

import { Timestamp } from "firebase-admin/firestore";

/**
 * Token
 */
export type Token = {
    amount: number;
    averagePrice: number; // útil para calcular valorização
    lastUpdated?: Timestamp;
}

// poderia ser possível cancelar uma venda
export type SellOrderStatus = "open" | "partial" | "closed" | "cancelled";

/**
 * Ordem de venda
 */
export type SellOrder = {
    // identificação
    id?: string;
    ownerId: string;
    sellerId?: string;
    sellerName?: string;
    startupId: string;

    // visual
    startupName: string;

    // dados da ordem
    amount: number;
    quantity?: number;
    remainingQuantity?: number;
    pricePerToken: number;
    unitPrice?: number;
    averagePrice: number;

    // dados para controle
    createdAt: Timestamp | string | null;
    updatedAt?: Timestamp | string | null;
    status: SellOrderStatus;
    totalValue?: number;
    type?: "sell";

}

/**
 * Metricas de token
 */
export type TokenMetrics = {
    valuation: number;
    profit: number;

    currentPrice: number;
    averagePrice: number;

    amount: number;
}

/**
 * Métricas completas de investimento do usuário.
 */
export type UserInvestment = {
    startupId: string;
    amount: number;

    currentPrice: number;
    averagePrice: number;

    valuation: number;
    profit: number;
}

/**
 * Resumo das métricas de investimento do usuário.
 */
export type UserInvestmentsSummary = {
    investments: UserInvestment[];

    investedValue: number;
    currentValue: number;
    totalProfit: number;
    totalValuation: number;
}
