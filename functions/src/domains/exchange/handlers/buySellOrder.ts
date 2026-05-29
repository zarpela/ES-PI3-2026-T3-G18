// Desenvolvido por Miguel Castro

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { buySellOrder } from "../repositories/exchangeRepository";

/**
 * Corpo esperado em request.data para comprar uma ordem de venda aberta.
 */
type BuySellOrderRequest = {
    amount?: number;
    orderId?: string;
    quantity?: number;
}

/**
 * Callable responsável por comprar uma ordem de venda aberta no balcão.
 *
 * Fluxo principal:
 * - exige usuário autenticado, usado como comprador da ordem;
 * - recebe o ID de uma ordem aberta em `request.data.orderId`;
 * - valida se o ID foi enviado como string;
 * - executa a compra no repositório, transferindo saldo do comprador para
 *   o vendedor, adicionando os tokens na carteira do comprador e marcando a
 *   ordem como concluída.
 *
 * @param request - Solicitação callable do Firebase.
 * @param request.auth.uid - ID do usuário autenticado que compra a ordem.
 * @param request.data.orderId - ID da ordem de venda que será comprada.
 *
 * @returns Objeto confirmado para o cliente após a compra:
 * {
 *   message: "Ordem comprada com sucesso.",
 *   data: {
 *     orderId: string
 *   }
 * }
 *
 * @throws HttpsError("unauthenticated") quando não houver usuário autenticado.
 * @throws HttpsError("invalid-argument") quando `orderId` não for uma string válida.
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
