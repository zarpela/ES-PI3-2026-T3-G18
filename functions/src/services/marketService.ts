/*
Autor: Abdallah
RA: [SEU RA]
*/

// Abdallah El-Khatib

import {
  buyMarketplaceOffer,
  buyStartupTokens,
  createSellOffer,
  getWalletTransactionHistory,
  listMarketplaceOffers,
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

export {getWalletTransactionHistory};

