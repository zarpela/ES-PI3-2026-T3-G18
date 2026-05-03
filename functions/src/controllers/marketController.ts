/*
Autor: [SEU NOME]
RA: [SEU RA]
*/

import {Request, Response} from "express";
import {
  buyTokens,
  getWalletTransactionHistory,
  sellTokens,
} from "../services/marketService";

function getErrorStatus(error: unknown): number {
  const status = (error as {status?: unknown}).status;

  if (typeof status === "number") {
    return status;
  }

  return 500;
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error && error.message) {
    return error.message;
  }

  return "Erro ao processar a operacao de mercado.";
}

function getAuthenticatedUserId(res: Response): string {
  return String(res.locals.authenticatedUserId ?? "");
}

export const buyTokensHandler = async (req: Request, res: Response) => {
  try {
    const result = await buyTokens({
      ...req.body,
      authenticatedUserId: getAuthenticatedUserId(res),
    });

    return res.status(200).json({
      ok: true,
      message: "Compra realizada com sucesso.",
      wallet: result.wallet,
      transaction: result.transaction,
    });
  } catch (error) {
    console.error("Erro ao comprar tokens.", error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};

export const sellTokensHandler = async (req: Request, res: Response) => {
  try {
    const result = await sellTokens({
      ...req.body,
      authenticatedUserId: getAuthenticatedUserId(res),
    });

    return res.status(200).json({
      ok: true,
      message: "Venda realizada com sucesso.",
      wallet: result.wallet,
      transaction: result.transaction,
    });
  } catch (error) {
    console.error("Erro ao vender tokens.", error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};

export const getWalletTransactionHistoryHandler = async (
  req: Request,
  res: Response,
) => {
  try {
    const transactions = await getWalletTransactionHistory({
      userId: String(req.params.userId ?? ""),
      authenticatedUserId: getAuthenticatedUserId(res),
    });

    return res.status(200).json({
      ok: true,
      message: "Historico encontrado com sucesso.",
      transactions,
    });
  } catch (error) {
    console.error("Erro ao consultar historico da carteira.", error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};
