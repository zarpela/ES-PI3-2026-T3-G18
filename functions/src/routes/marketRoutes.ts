/*
Autor: [SEU NOME]
RA: [SEU RA]
*/

import express from "express";
import {
  buyTokensHandler,
  getWalletTransactionHistoryHandler,
  sellTokensHandler,
} from "../controllers/marketController";
import {requireAuthenticatedUser} from "../middlewares/authMiddleware";

const router = express.Router();

router.use(requireAuthenticatedUser);
router.post("/buy", buyTokensHandler);
router.post("/sell", sellTokensHandler);
router.get("/history/:userId", getWalletTransactionHistoryHandler);

export default router;
