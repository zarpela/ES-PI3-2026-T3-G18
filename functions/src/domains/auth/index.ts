import express from "express";
import {requireAuthenticatedUser} from "../../middlewares/authMiddleware";
import {forgotPasswordHandler} from "./handlers/forgotPasswordHandler";
import {requestLoginMfaHandler} from "./handlers/requestLoginMfaHandler";
import {resetPasswordHandler} from "./handlers/resetPasswordHandler";
import {verifyLoginMfaHandler} from "./handlers/verifyLoginMfaHandler";
import {verifyResetCodeHandler} from "./handlers/verifyResetCodeHandler";

const router = express.Router();

router.post("/forgot-password", forgotPasswordHandler);
router.post("/request-login-mfa", requireAuthenticatedUser, requestLoginMfaHandler);
router.post("/verify-reset-code", verifyResetCodeHandler);
router.post("/verify-login-mfa", requireAuthenticatedUser, verifyLoginMfaHandler);
router.post("/reset-password", resetPasswordHandler);

export default router;
