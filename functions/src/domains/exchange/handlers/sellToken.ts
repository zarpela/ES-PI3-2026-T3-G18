// Desenvolvido por Miguel Afonso Castro de Almeida - RA: 25016044

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { sellTokens } from "../repositories/exchangeRepository";

/**
 * Corpo esperado em request.data para criar uma ordem de venda de tokens.
 */
type SellTokensRequest = {
    startupId?: string;
    amount?: number;
    pricePerToken?: number;
}

/**
 * Callable responsável por criar uma ordem de venda de tokens no balcão.
 *
 * Fluxo principal:
 * - exige usuário autenticado, usado como vendedor da ordem;
 * - recebe a startup, quantidade e preço unitário em `request.data`;
 * - valida se `startupId` é string e se `amount` e `pricePerToken` são números
 *   maiores que zero;
 * - executa a venda no repositório, removendo os tokens da carteira do vendedor
 *   e criando uma ordem com status `"open"`.
 *
 * @param request - Solicitação callable do Firebase.
 * @param request.auth.uid - ID do usuário autenticado que cria a ordem.
 * @param request.data.startupId - ID da startup cujos tokens serão vendidos.
 * @param request.data.amount - Quantidade de tokens colocados à venda.
 * @param request.data.pricePerToken - Preço pedido por token na ordem.
 *
 * @returns Objeto confirmado para o cliente após a criação da ordem:
 * {
 *   message: "Ordem de venda criada com sucesso.",
 *   data: {
 *     startupId: string,
 *     amount: number,
 *     pricePerToken: number
 *   }
 * }
 *
 * @throws HttpsError("unauthenticated") quando não houver usuário autenticado.
 * @throws HttpsError("invalid-argument") quando `startupId`, `amount` ou
 * `pricePerToken` forem inválidos.
 */
export const sellToken = onCall(
    { region: "southamerica-east1" },
    async (request) => {

        const uid = request.auth?.uid;

        // usuário autenticado
        if (!uid) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado.");
        }

        // evita quebra se request.data for undefined
        const data = (request.data ?? {}) as Partial<SellTokensRequest>;

        const startupId = data.startupId;
        const amount = data.amount;
        const pricePerToken = data.pricePerToken;

        // valida startupId
        if (!startupId || typeof startupId !== "string") {
            throw new HttpsError("invalid-argument", "Startup inválida.");
        }

        // valida quantidade
        if (typeof amount !== "number" || amount <= 0) {
            throw new HttpsError("invalid-argument", "Quantidade inválida.");
        }

        // valida preço
        if (typeof pricePerToken !== "number" || pricePerToken <= 0) {
            throw new HttpsError("invalid-argument", "Preço inválido.");
        }

        // executa venda
        await sellTokens(
            uid,
            startupId,
            amount,
            pricePerToken,
        );

        return {
            message: "Ordem de venda criada com sucesso.",
            data: {startupId, amount, pricePerToken}
        };

    }
);
