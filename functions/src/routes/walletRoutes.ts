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

const router = express.Router();

router.post("/wallet/create", createWalletHandler);
router.get("/wallet/:userId", getWalletHandler);
router.post("/wallet/add-balance", addBalanceHandler);
router.get("/wallet/:userId/tokens", listWalletTokensHandler);

export default router;
