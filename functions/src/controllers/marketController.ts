//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import {Request, Response} from "express";
import {
  buyOffer,
  buyTokens,
  cancelOffer,
  getMarketplaceOffers,
  getWalletTransactionHistory,
  sellTokens,
  updateOffer,
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
    const overview = await buyTokens({
      ...req.body,
      authenticatedUserId: getAuthenticatedUserId(res),
    });

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
    const result = await sellTokens({
      ...req.body,
      authenticatedUserId: getAuthenticatedUserId(res),
    });

    return res.status(200).json({
      ok: true,
      message: "Oferta de venda criada com sucesso.",
      wallet: result.wallet,
      tokens: result.tokens,
      recentTransactions: result.recentTransactions,
      offer: result.offer,
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

export const listMarketplaceOffersHandler = async (req: Request, res: Response) => {
  try {
    const offers = await getMarketplaceOffers({
      stage: String(req.query.stage ?? ""),
      startupId: String(req.query.startupId ?? ""),
    });

    return res.status(200).json({
      ok: true,
      count: offers.length,
      offers,
      data: offers,
    });
  } catch (error) {
    console.error("Erro ao listar ofertas do marketplace.", error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};

export const buyMarketplaceOfferHandler = async (req: Request, res: Response) => {
  try {
    const overview = await buyOffer({
      ...req.body,
      offerId: String(req.params.offerId ?? req.body.offerId ?? ""),
      authenticatedUserId: getAuthenticatedUserId(res),
    });

    return res.status(200).json({
      ok: true,
      message: "Oferta comprada com sucesso.",
      wallet: overview.wallet,
      tokens: overview.tokens,
      recentTransactions: overview.recentTransactions,
    });
  } catch (error) {
    console.error("Erro ao comprar oferta do marketplace.", error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};

export const cancelMarketplaceOfferHandler = async (
  req: Request,
  res: Response,
) => {
  try {
    const overview = await cancelOffer({
      ...req.body,
      offerId: String(req.params.offerId ?? req.body.offerId ?? ""),
      authenticatedUserId: getAuthenticatedUserId(res),
    });

    return res.status(200).json({
      ok: true,
      message: "Oferta cancelada com sucesso.",
      wallet: overview.wallet,
      tokens: overview.tokens,
      recentTransactions: overview.recentTransactions,
    });
  } catch (error) {
    console.error("Erro ao cancelar oferta do marketplace.", error);

    return res.status(getErrorStatus(error)).json({
      ok: false,
      error: getErrorMessage(error),
      message: getErrorMessage(error),
    });
  }
};

export const updateMarketplaceOfferHandler = async (
  req: Request,
  res: Response,
) => {
  try {
    const overview = await updateOffer({
      ...req.body,
      offerId: String(req.params.offerId ?? req.body.offerId ?? ""),
      authenticatedUserId: getAuthenticatedUserId(res),
    });

    return res.status(200).json({
      ok: true,
      message: "Oferta alterada com sucesso.",
      wallet: overview.wallet,
      tokens: overview.tokens,
      recentTransactions: overview.recentTransactions,
    });
  } catch (error) {
    console.error("Erro ao alterar oferta do marketplace.", error);

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
