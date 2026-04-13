import * as functions from "firebase-functions";
import express from "express";

const app = express();

app.use(express.json());

// This backend no longer handles password reset.
// The Flutter app now uses Firebase Auth native email reset flow directly.
app.post("/login", (req, res) => {
  const {email, senha} = req.body;

  if (email === "admin@test.com" && senha === "123") {
    return res.json({message: "Login ok"});
  }

  return res.status(401).json({error: "Credenciais invalidas"});
});

export const api = functions.https.onRequest(app);
