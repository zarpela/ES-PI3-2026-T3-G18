//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import express from "express";
import {
  buyTokensHandler,
  createWalletHandler,
  depositBalanceHandler,
  getWalletHandler,
  getWalletTransactionHistoryHandler,
  listWalletTokensHandler,
  sellTokensHandler,
  withdrawBalanceHandler,
} from "../controllers/walletController";
import {requireAuthenticatedUser} from "../middlewares/authMiddleware";

const router = express.Router();

router.use("/wallet", requireAuthenticatedUser);

router.post("/wallet/create", createWalletHandler);

router.get("/wallet/:userId", getWalletHandler);
router.post("/wallet/:userId/deposit", depositBalanceHandler);
router.post("/wallet/:userId/withdraw", withdrawBalanceHandler);
router.post("/wallet/:userId/buy", buyTokensHandler);
router.post("/wallet/:userId/sell", sellTokensHandler);
router.get("/wallet/:userId/tokens", listWalletTokensHandler);
router.get("/wallet/:userId/transactions", getWalletTransactionHistoryHandler);

// Abdallah Ali Borges El-Khatib - RA: 25018711 ajustou estas rotas para manter compatibilidade com o frontend antigo.
router.post("/wallet/add-balance", depositBalanceHandler);
router.post("/wallet/withdraw-balance", withdrawBalanceHandler);

export default router;
