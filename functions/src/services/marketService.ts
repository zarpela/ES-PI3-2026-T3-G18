//feito por Abdallah
import {
  buyMarketplaceOffer,
  buyStartupTokens,
  cancelMarketplaceOffer,
  createSellOffer,
  getWalletTransactionHistory,
  listMarketplaceOffers,
  updateMarketplaceOffer,
} from "./walletService";

type MarketOperationInput = {
  authenticatedUserId?: string;
  historyLimit?: number | string;
  offerId?: string;
  price?: number | string;
  quantity?: number | string;
  startupId?: string;
  startupName?: string;
  startupSymbol?: string;
  unitPrice?: number | string;
  userId?: string;
};

type MarketOffersInput = {
  stage?: string;
  startupId?: string;
};

export const buyTokens = async (data: MarketOperationInput) =>
  buyStartupTokens({
    ...data,
    unitPrice: data.unitPrice ?? data.price,
  });

export const sellTokens = async (data: MarketOperationInput) =>
  createSellOffer({
    ...data,
    unitPrice: data.unitPrice ?? data.price,
  });

export const getMarketplaceOffers = async (data: MarketOffersInput = {}) =>
  listMarketplaceOffers(data);

export const buyOffer = async (data: MarketOperationInput) =>
  buyMarketplaceOffer(data);

export const cancelOffer = async (data: MarketOperationInput) =>
  cancelMarketplaceOffer(data);

export const updateOffer = async (data: MarketOperationInput) =>
  updateMarketplaceOffer({
    ...data,
    unitPrice: data.unitPrice ?? data.price,
  });

export {getWalletTransactionHistory};
