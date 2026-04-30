/*
Autor: [COLOQUE SEU NOME COMPLETO]
RA: [COLOQUE SEU RA]
*/

import {Request, Response} from "express";
import {
  addBalanceToWallet,
  createWallet,
  getWalletByUserId,
  listWalletTokens,
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

export const createWalletHandler = async (req: Request, res: Response) => {
  try {
    const wallet = await createWallet(req.body);

    return res.status(201).json({
      ok: true,
      message: "Carteira criada com sucesso.",
      wallet,
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
    const wallet = await getWalletByUserId(String(req.params.userId ?? ""));

    return res.status(200).json({
      ok: true,
      message: "Carteira encontrada com sucesso.",
      wallet,
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

export const addBalanceHandler = async (req: Request, res: Response) => {
  try {
    const wallet = await addBalanceToWallet(req.body);

    return res.status(200).json({
      ok: true,
      message: "Saldo adicionado com sucesso.",
      wallet,
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

export const listWalletTokensHandler = async (req: Request, res: Response) => {
  try {
    const tokens = await listWalletTokens(String(req.params.userId ?? ""));

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
