import express from "express";
import {createAccount} from "../controllers/userController";

const router = express.Router();

router.post("/create-account", createAccount);
router.post("/register", createAccount);

export default router;
