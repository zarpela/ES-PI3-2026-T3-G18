// Desenvolvido por Miguel Castro

import { onCall } from "firebase-functions/v2/https";
import { getSellOrders } from "../repositories/exchangeRepository";

/**
 * Callable responsável por listar as ordens de venda abertas no balcão.
 *
 * Fluxo principal:
 * - não exige dados em `request.data`;
 * - consulta as ordens com status `"open"`;
 * - retorna a quantidade encontrada e a lista completa para exibição no balcão.
 *
 * @returns Objeto com contador e lista de ordens abertas:
 * {
 *   count: number,
 *   data: [
 *     {
 *       id: string,
 *       ownerId: string,
 *       startupId: string,
 *       startupName: string,
 *       amount: number,
 *       pricePerToken: number,
 *       averagePrice: number,
 *       createdAt: Timestamp,
 *       status: "open"
 *     }
 *   ]
 * }
 *
 * `averagePrice` é o preço médio pago pelo vendedor quando adquiriu os tokens;
 * `pricePerToken` é o preço pedido na ordem de venda.
 */
export const getSellOrdersHandler = onCall(
    { region: "southamerica-east1" },
    async () => {

        const orders = await getSellOrders();

        return {
            count: orders.length,
            data: orders,
        };
    }
);
