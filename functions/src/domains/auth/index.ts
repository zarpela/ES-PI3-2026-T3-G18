//feito por Abdallah Ali Borges El-Khatib - RA: 25018711

import express from "express";
import {requireAuthenticatedUser} from "../../middlewares/authMiddleware";
import {forgotPasswordHandler} from "./handlers/forgotPasswordHandler";
import {requestLoginMfaHandler} from "./handlers/requestLoginMfaHandler";
import {resetPasswordHandler} from "./handlers/resetPasswordHandler";
import {verifyLoginMfaHandler} from "./handlers/verifyLoginMfaHandler";
import {verifyResetCodeHandler} from "./handlers/verifyResetCodeHandler";
import {getMfaStatusHandler} from "./handlers/getMfaStatusHandler";
import {enableMfaHandler} from "./handlers/enableMfaHandler";
import {disableMfaHandler} from "./handlers/disableMfaHandler";
import {requestMfaLoginCodeHandler} from "./handlers/requestMfaLoginCodeHandler";
import {verifyMfaLoginCodeHandler} from "./handlers/verifyMfaLoginCodeHandler";

const router = express.Router();

router.post("/forgot-password", forgotPasswordHandler);
router.post("/request-login-mfa", requireAuthenticatedUser, requestLoginMfaHandler);
router.post("/verify-reset-code", verifyResetCodeHandler);
router.post("/verify-login-mfa", requireAuthenticatedUser, verifyLoginMfaHandler);
router.post("/reset-password", resetPasswordHandler);

router.get("/mfa/status", requireAuthenticatedUser, getMfaStatusHandler);
router.post("/mfa/enable", requireAuthenticatedUser, enableMfaHandler);
router.post("/mfa/disable", requireAuthenticatedUser, disableMfaHandler);
router.post("/mfa/request-code", requireAuthenticatedUser, requestMfaLoginCodeHandler);
router.post("/mfa/verify-code", requireAuthenticatedUser, verifyMfaLoginCodeHandler);

export default router;
