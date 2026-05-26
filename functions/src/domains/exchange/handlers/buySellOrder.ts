// Desenvolvido por Miguel Castro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { buySellOrder } from "../repositories/exchangeRepository";

/**
 * Padronização do request
 */
type BuySellOrderRequest = {
    amount?: number;
    orderId?: string;
    quantity?: number;
}

/**
 * Compra de ordem de venda existente. O comprador paga o preço por token 
 * definido na ordem e recebe os tokens comprados, enquanto o vendedor 
 * recebe o dinheiro da venda. A ordem é removida do sistema.
 * As ordens de vendas são vistas no balcão
 */
/**
 * Função callable para comprar uma ordem de venda aberta.
 *
 * @param request - Solicitação do cliente contendo o ID da ordem.
 *   - data.orderId: ID da ordem de venda a ser comprada.
 * @returns Retorna mensagem de sucesso e o ID da ordem comprada.
 */
export const buySellOrderHandler = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        // usuário autenticado
        const buyerId = request.auth?.uid;

        if (!buyerId) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado.");
        }

        // evita quebra se request.data for undefined
        const data = (request.data ?? {}) as Partial<BuySellOrderRequest>;
        const orderId = data.orderId;
        const amount = data.quantity ?? data.amount;

        // valida orderId
        if (!orderId || typeof orderId !== "string") 
        {
            throw new HttpsError("invalid-argument", "Ordem inválida.");
        }

        // executa compra da ordem
        await buySellOrder(buyerId, orderId, amount);

        return {
            message: "Ordem comprada com sucesso.",
            data: {orderId}
        };

    }
);
