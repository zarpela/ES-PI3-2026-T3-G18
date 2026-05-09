import express from "express";
import { createAccountHandler } from "./handlers/createAccountHandler";
import { testFirestoreHandler } from "./handlers/testFirestoreHandler";
import { uploadProfilePhotoHandler } from "./handlers/uploadProfilePhotoHandler";
import { getProfilePhotoHandler } from "./handlers/getProfilePhotoHandler";

const router = express.Router();

router.post("/create-account", createAccountHandler);
router.post("/register", createAccountHandler);
router.get("/test-firestore", testFirestoreHandler);
router.post("/upload-profile-photo", uploadProfilePhotoHandler);
router.get("/profile-photo", getProfilePhotoHandler);

export default router;
