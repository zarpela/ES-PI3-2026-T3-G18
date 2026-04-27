import express from "express";
import {db} from "../config/firebase";

const router = express.Router();

router.get("/test-firestore", async (req, res) => {
  try {
    await db.collection("teste").add({
      ok: true,
      createdAt: new Date(),
    });
    res.json({ok: true, message: "Salvou no Firestore!"});
  } catch (error) {
    console.error(error);
    res.status(500).json({ok: false, error: "Erro ao salvar"});
  }
});

export default router;