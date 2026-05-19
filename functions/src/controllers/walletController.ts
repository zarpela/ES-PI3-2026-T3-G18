/*
Autor: [COLOQUE SEU NOME COMPLETO]
RA: [COLOQUE SEU RA]
*/

import {Request, Response} from "express";
import {
  addBalanceToWallet,
  buyStartupTokens,
  createWallet,
  getWalletByUserId,
  getWalletTransactionHistory,
  listWalletTokens,
  sellStartupTokens,
  withdrawBalanceFromWallet,
} from "../services/walletService";

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

  return "Erro ao processar a carteira.";
}

function getAuthenticatedUserId(res: Response): string {
  return String(res.locals.authenticatedUserId ?? "");
}

function buildWalletRequest(req: Request, res: Response) {
  return {
    ...req.body,
    ...req.query,
    userId: String(req.params.userId ?? req.body.userId ?? ""),
    authenticatedUserId: getAuthenticatedUserId(res),
  };
}

export const createWalletHandler = async (req: Request, res: Response) => {
  try {
    const overview = await createWallet({
      ...req.body,
      ...req.query,
      authenticatedUserId: getAuthenticatedUserId(res),
    });

    return res.status(200).json({
      ok: true,
      message: "Carteira sincronizada com sucesso.",
      wallet: overview.wallet,
      tokens: overview.tokens,
      recentTransactions: overview.recentTransactions,
    });
  } catch (error) {
    console.error(error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};

export const getWalletHandler = async (req: Request, res: Response) => {
  try {
    const overview = await getWalletByUserId(buildWalletRequest(req, res));

    return res.status(200).json({
      ok: true,
      message: "Carteira encontrada com sucesso.",
      wallet: overview.wallet,
      tokens: overview.tokens,
      recentTransactions: overview.recentTransactions,
    });
  } catch (error) {
    console.error(error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};

export const depositBalanceHandler = async (req: Request, res: Response) => {
  try {
    const overview = await addBalanceToWallet(buildWalletRequest(req, res));

    return res.status(200).json({
      ok: true,
      message: "Deposito realizado com sucesso.",
      wallet: overview.wallet,
      tokens: overview.tokens,
      recentTransactions: overview.recentTransactions,
    });
  } catch (error) {
    console.error(error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};

export const withdrawBalanceHandler = async (req: Request, res: Response) => {
  try {
    const overview = await withdrawBalanceFromWallet(buildWalletRequest(req, res));

    return res.status(200).json({
      ok: true,
      message: "Saque realizado com sucesso.",
      wallet: overview.wallet,
      tokens: overview.tokens,
      recentTransactions: overview.recentTransactions,
    });
  } catch (error) {
    console.error(error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};

export const buyTokensHandler = async (req: Request, res: Response) => {
  try {
    const overview = await buyStartupTokens(buildWalletRequest(req, res));

    return res.status(200).json({
      ok: true,
      message: "Compra realizada com sucesso.",
      wallet: overview.wallet,
      tokens: overview.tokens,
      recentTransactions: overview.recentTransactions,
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
    const overview = await sellStartupTokens(buildWalletRequest(req, res));

    return res.status(200).json({
      ok: true,
      message: "Venda realizada com sucesso.",
      wallet: overview.wallet,
      tokens: overview.tokens,
      recentTransactions: overview.recentTransactions,
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

export const listWalletTokensHandler = async (req: Request, res: Response) => {
  try {
    const tokens = await listWalletTokens(buildWalletRequest(req, res));

    return res.status(200).json({
      ok: true,
      message: "Tokens encontrados com sucesso.",
      tokens,
    });
  } catch (error) {
    console.error(error);

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
    const transactions = await getWalletTransactionHistory(
      buildWalletRequest(req, res),
    );

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
