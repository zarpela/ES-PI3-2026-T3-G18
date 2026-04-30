/*
Autor: [COLOQUE SEU NOME COMPLETO]
RA: [COLOQUE SEU RA]
*/

import express from "express";
import {
  addBalanceHandler,
  createWalletHandler,
  getWalletHandler,
  listWalletTokensHandler,
} from "../controllers/walletController";
import {requireAuthenticatedUser} from "../middlewares/authMiddleware";

const router = express.Router();

router.use("/wallet", requireAuthenticatedUser);
router.post("/wallet/create", createWalletHandler);
router.get("/wallet/:userId", getWalletHandler);
router.post("/wallet/add-balance", addBalanceHandler);
router.get("/wallet/:userId/tokens", listWalletTokensHandler);

export default router;
