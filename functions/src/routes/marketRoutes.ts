/*
Autor: Abdallah
RA: [SEU RA]
*/

import express from "express";
import {
  buyMarketplaceOfferHandler,
  buyTokensHandler,
  cancelMarketplaceOfferHandler,
  getWalletTransactionHistoryHandler,
  listMarketplaceOffersHandler,
  sellTokensHandler,
  updateMarketplaceOfferHandler,
} from "../controllers/marketController";
import {requireAuthenticatedUser} from "../middlewares/authMiddleware";

const router = express.Router();

router.use(requireAuthenticatedUser);
router.get("/offers", listMarketplaceOffersHandler);
router.post("/offers/:offerId/buy", buyMarketplaceOfferHandler);
router.patch("/offers/:offerId", updateMarketplaceOfferHandler);
router.delete("/offers/:offerId", cancelMarketplaceOfferHandler);
router.post("/buy", buyTokensHandler);
router.post("/sell", sellTokensHandler);
router.get("/history/:userId", getWalletTransactionHistoryHandler);

export default router;
