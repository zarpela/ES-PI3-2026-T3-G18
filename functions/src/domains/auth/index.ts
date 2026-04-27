import express from "express";
import {forgotPasswordHandler} from "./handlers/forgotPasswordHandler";
import {resetPasswordHandler} from "./handlers/resetPasswordHandler";
import {verifyResetCodeHandler} from "./handlers/verifyResetCodeHandler";

const router = express.Router();

router.post("/forgot-password", forgotPasswordHandler);
router.post("/verify-reset-code", verifyResetCodeHandler);
router.post("/reset-password", resetPasswordHandler);

export default router;
