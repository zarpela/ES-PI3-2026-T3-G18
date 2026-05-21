// Desenvolvido por Miguel Castro

import { onCall } from "firebase-functions/v2/https";
import { getSellOrders } from "../repositories/exchangeRepository";

/**
 * Função callable para buscar todas as ordens de venda abertas.
 *
 * @returns Retorna o contador e a lista de ordens abertas.
 *   - count: total de ordens retornadas.
 *   - data: array de ordens abertas.
 *     Cada objeto de ordem contém:
 *       - id: ID da ordem.
 *       - ownerId: ID do usuário vendedor.
 *       - startupId: ID da startup cujos tokens estão à venda.
 *       - startupName: nome da startup exibido no pedido.
 *       - amount: quantidade de tokens à venda.
 *       - pricePerToken: preço pedido por token.
 *       - averagePrice: preço médio de aquisição do token pelo vendedor.
 *       - createdAt: timestamp de criação da ordem.
 *       - status: status atual da ordem (deve ser "open").
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