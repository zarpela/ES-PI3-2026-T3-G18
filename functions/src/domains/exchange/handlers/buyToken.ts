// Desenvolvido por Miguel Afonso Castro de Almeida - RA: 25016044
//feito por Abdallah Ali Borges El-Khatib - RA: 25018711

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { buyTokens } from "../repositories/exchangeRepository";

/**
 * Corpo esperado em request.data para compra direta de tokens de uma startup.
 */
type BuyTokensRequest = {
    startupId?: string;
    amount?: number;
}

/**
 * Callable responsável por comprar tokens diretamente da startup.
 *
 * Fluxo principal:
 * - exige usuário autenticado, usado como comprador;
 * - recebe a startup alvo e a quantidade de tokens em `request.data`;
 * - valida se `startupId` é string e se `amount` é número maior que zero;
 * - executa a compra no repositório, debitando o saldo da carteira,
 *   atualizando ou criando o token do usuário e ajustando os dados da startup.
 *
 * @param request - Solicitação callable do Firebase.
 * @param request.auth.uid - ID do usuário autenticado que realiza a compra.
 * @param request.data.startupId - ID da startup cujos tokens serão comprados.
 * @param request.data.amount - Quantidade de tokens que o usuário deseja comprar.
 *
 * @returns Objeto confirmado para o cliente após a compra:
 * {
 *   message: "Compra realizada com sucesso.",
 *   data: {
 *     startupId: string,
 *     amount: number
 *   }
 * }
 *
 * @throws HttpsError("unauthenticated") quando não houver usuário autenticado.
 * @throws HttpsError("invalid-argument") quando `startupId` ou `amount` forem inválidos.
 */
export const buyToken = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const uid = request.auth?.uid;

        if (!uid) {
            throw new HttpsError("unauthenticated", "Usuário não autenticado.");
        }

        // evita quebra se request.data for undefined
        const data = (request.data ?? {}) as Partial<BuyTokensRequest>;

        const startupId = data.startupId;
        const amount = data.amount;

        // valida startupId
        if (!startupId || typeof startupId !== "string") {
            throw new HttpsError("invalid-argument", "Startup inválida.");
        }

        // valida quantidade
        if (typeof amount !== "number" || amount <= 0){
            throw new HttpsError("invalid-argument", "Quantidade inválida.");
        }

        // executa compra
        await buyTokens(uid, startupId, amount);

        return {
            message: "Compra realizada com sucesso.",
            data: {startupId, amount}
        };

});
