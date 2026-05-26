/*
Autor: Abdallah
RA: [SEU RA]
*/

import express from "express";
import {
  buyMarketplaceOfferHandler,
  buyTokensHandler,
  getWalletTransactionHistoryHandler,
  listMarketplaceOffersHandler,
  sellTokensHandler,
} from "../controllers/marketController";
import {requireAuthenticatedUser} from "../middlewares/authMiddleware";

const router = express.Router();

router.use(requireAuthenticatedUser);
router.get("/offers", listMarketplaceOffersHandler);
router.post("/offers/:offerId/buy", buyMarketplaceOfferHandler);
router.post("/buy", buyTokensHandler);
router.post("/sell", sellTokensHandler);
router.get("/history/:userId", getWalletTransactionHistoryHandler);

export default router;
