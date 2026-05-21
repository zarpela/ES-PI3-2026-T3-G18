/*
Autor: Abdallah
RA: [SEU RA]
*/

import {
  buyStartupTokens,
  getWalletTransactionHistory,
  sellStartupTokens,
} from "./walletService";

type MarketOperationInput = {
  authenticatedUserId?: string;
  historyLimit?: number | string;
  price?: number | string;
  quantity?: number | string;
  startupId?: string;
  startupName?: string;
  startupSymbol?: string;
  unitPrice?: number | string;
  userId?: string;
};

export const buyTokens = async (data: MarketOperationInput) =>
  buyStartupTokens({
    ...data,
    unitPrice: data.unitPrice ?? data.price,
  });

export const sellTokens = async (data: MarketOperationInput) =>
  sellStartupTokens({
    ...data,
    unitPrice: data.unitPrice ?? data.price,
  });

export {getWalletTransactionHistory};
