import express from "express";
import {forgotPasswordHandler} from "./handlers/forgotPasswordHandler";
import {resetPasswordHandler} from "./handlers/resetPasswordHandler";
import {verifyResetCodeHandler} from "./handlers/verifyResetCodeHandler";
import {requireAuthenticatedUser} from "../../middlewares/authMiddleware";
import {getMfaStatusHandler} from "./handlers/getMfaStatusHandler";
import {enableMfaHandler} from "./handlers/enableMfaHandler";
import {disableMfaHandler} from "./handlers/disableMfaHandler";
import {requestMfaLoginCodeHandler} from "./handlers/requestMfaLoginCodeHandler";
import {verifyMfaLoginCodeHandler} from "./handlers/verifyMfaLoginCodeHandler";

const router = express.Router();

router.post("/forgot-password", forgotPasswordHandler);
router.post("/verify-reset-code", verifyResetCodeHandler);
router.post("/reset-password", resetPasswordHandler);

router.get("/mfa/status", requireAuthenticatedUser, getMfaStatusHandler);
router.post("/mfa/enable", requireAuthenticatedUser, enableMfaHandler);
router.post("/mfa/disable", requireAuthenticatedUser, disableMfaHandler);
router.post("/mfa/request-code", requireAuthenticatedUser, requestMfaLoginCodeHandler);
router.post("/mfa/verify-code", requireAuthenticatedUser, verifyMfaLoginCodeHandler);

export default router;
