import express from "express";
import {createAccountHandler} from "./handlers/createAccountHandler";
import {testFirestoreHandler} from "./handlers/testFirestoreHandler";

const router = express.Router();

router.post("/create-account", createAccountHandler);
router.post("/register", createAccountHandler);
router.get("/test-firestore", testFirestoreHandler);

export default router;
