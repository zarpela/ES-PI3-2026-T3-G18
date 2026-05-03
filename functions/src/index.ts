import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import type {UserRecord} from "firebase-admin/auth";
import {randomInt} from "crypto";
import cors from "cors";
import express from "express";
import fs from "fs";
//import nodemailer from "nodemailer";
import path from "path";
import {auth, db} from "./config/firebase";
import marketRoutes from "./routes/marketRoutes";
import testRoutes from "./routes/testRoutes";
import userRoutes from "./routes/userRoutes";
import walletRoutes from "./routes/walletRoutes";

type LocalMailConfig = {
  mailUser?: string;
  mailPass?: string;
};

type StoredResetCode = {
  code: string;
  email: string;
  expiresAt: string;
  uid: string;
};

const app = express();
const passwordResetCodesCollection = "passwordResetCodes";
const resetCodeExpiresInMinutes = 15;

app.use(cors({origin: true}));
app.use(express.json());
app.use(userRoutes);
app.use(testRoutes);
app.use("/market", marketRoutes);
app.use(walletRoutes);

function loadJsonFile<T>(fileName: string): T | undefined {
  const filePath = path.resolve(__dirname, fileName);

  if (!fs.existsSync(filePath)) {
    return undefined;
  }

  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8")) as T;
  } catch (error) {
    logger.error(`Nao foi possivel ler ${fileName}.`, error);
    return undefined;
  }
}

function loadLocalMailConfig(): LocalMailConfig {
  return loadJsonFile<LocalMailConfig>("../local-mail.config.json") ?? {};
}

function normalizeEmail(value: string): string {
  return value.trim().toLowerCase();
}

function generateVerificationCode(): string {
  return randomInt(100000, 1000000).toString();
}

function isExpired(expiresAt: string): boolean {
  return new Date(expiresAt).getTime() < Date.now();
}

async function findUserByEmail(email: string): Promise<UserRecord | null> {
  try {
    return await auth.getUserByEmail(email);
  } catch (error) {
    const code = (error as {code?: string}).code;

    if (code === "auth/user-not-found" || code === "auth/invalid-email") {
      return null;
    }

    throw error;
  }
}

async function readResetCode(email: string): Promise<StoredResetCode | null> {
  const snapshot = await db
    .collection(passwordResetCodesCollection)
    .doc(normalizeEmail(email))
    .get();

  if (!snapshot.exists) {
    return null;
  }

  return snapshot.data() as StoredResetCode;
}

async function storeResetCode(record: StoredResetCode): Promise<void> {
  await db
    .collection(passwordResetCodesCollection)
    .doc(record.email)
    .set({
      ...record,
      updatedAt: new Date().toISOString(),
    });
}

async function clearResetCode(email: string): Promise<void> {
  await db
    .collection(passwordResetCodesCollection)
    .doc(normalizeEmail(email))
    .delete();
}

function buildForgotPasswordResponse() {
  return {
    message: "Se o e-mail estiver cadastrado, enviaremos as instrucoes de recuperacao.",
  };
}

async function invalidateResetCode(email: string): Promise<void> {
  await clearResetCode(email);
}

async function sendPasswordResetEmail(
  to: string,
  code: string,
): Promise<boolean> {
  const localMailConfig = loadLocalMailConfig();
  const mailUser = process.env.MAIL_USER || localMailConfig.mailUser;
  const mailPass = process.env.MAIL_PASS || localMailConfig.mailPass;

  if (!mailUser || !mailPass) {
    logger.warn(
      "MAIL_USER/MAIL_PASS nao configurados. O envio de e-mail de recuperacao nao foi realizado.",
    );
    return false;
  }

  const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 587,
    secure: false,
    auth: {
      user: mailUser,
      pass: mailPass,
    },
  });

  await transporter.sendMail({
    from: `"MesclaInvest" <${mailUser}>`,
    to,
    subject: "Codigo de recuperacao de senha",
    html: `
      <h2>Recuperacao de senha</h2>
      <p>Use o codigo abaixo para redefinir sua senha:</p>
      <h1 style="letter-spacing:4px">${code}</h1>
      <p>Se voce nao fez essa solicitacao, ignore este email.</p>
    `,
  });

  return true;
}

app.get("/", (_req, res) => {
  return res.json({message: "Backend rodando."});
});

app.post("/forgot-password", async (req, res) => {
  const email = normalizeEmail(String(req.body.identifier ?? req.body.email ?? ""));

  if (!email) {
    return res.status(400).json({
      message: "identifier e obrigatorio.",
    });
  }

  try {
    const user = await findUserByEmail(email);

    if (!user) {
      await invalidateResetCode(email);
      return res.status(200).json(buildForgotPasswordResponse());
    }

    const code = generateVerificationCode();
    const expiresAt = new Date(
      Date.now() + resetCodeExpiresInMinutes * 60 * 1000,
    ).toISOString();

    await storeResetCode({
      code,
      email,
      expiresAt,
      uid: user.uid,
    });

    const emailSent = await sendPasswordResetEmail(email, code);

    if (!emailSent) {
      await invalidateResetCode(email);
    }

    return res.status(200).json(buildForgotPasswordResponse());
  } catch (error) {
    await invalidateResetCode(email);
    logger.error("Erro ao enviar e-mail de recuperacao.", error);
    return res.status(200).json(buildForgotPasswordResponse());
  }
});

app.post("/verify-reset-code", async (req, res) => {
  const email = normalizeEmail(String(req.body.email ?? ""));
  const code = String(req.body.code ?? "").trim();

  if (!email || !code) {
    return res.status(400).json({
      message: "email e code sao obrigatorios.",
    });
  }

  try {
    const user = await findUserByEmail(email);
    const resetCode = await readResetCode(email);

    if (!user || !resetCode) {
      await invalidateResetCode(email);
      return res.status(400).json({
        message: "Codigo de verificacao invalido.",
      });
    }

    if (resetCode.code !== code || resetCode.uid !== user.uid) {
      await invalidateResetCode(email);
      return res.status(400).json({
        message: "Codigo de verificacao invalido.",
      });
    }

    if (isExpired(resetCode.expiresAt)) {
      await invalidateResetCode(email);
      return res.status(400).json({
        message: "Codigo expirado. Solicite um novo codigo.",
      });
    }

    return res.status(200).json({
      message: "Codigo validado com sucesso.",
    });
  } catch (error) {
    logger.error("Erro ao validar codigo de recuperacao.", error);
    return res.status(500).json({
      message: "Nao foi possivel validar o codigo informado.",
    });
  }
});

app.post("/reset-password", async (req, res) => {
  const email = normalizeEmail(String(req.body.email ?? ""));
  const novaSenha = String(req.body.novaSenha ?? "");
  const code = String(req.body.code ?? "").trim();

  if (!email || !novaSenha || !code) {
    return res.status(400).json({
      message: "email, novaSenha e code sao obrigatorios.",
    });
  }

  if (novaSenha.length < 8) {
    return res.status(400).json({
      message: "A senha deve ter pelo menos 8 caracteres.",
    });
  }

  try {
    const user = await findUserByEmail(email);
    const resetCode = await readResetCode(email);

    if (!user || !resetCode) {
      await invalidateResetCode(email);
      return res.status(400).json({
        message: "Codigo de verificacao invalido.",
      });
    }

    if (resetCode.code !== code || resetCode.uid !== user.uid) {
      await invalidateResetCode(email);
      return res.status(400).json({
        message: "Codigo de verificacao invalido.",
      });
    }

    if (isExpired(resetCode.expiresAt)) {
      await invalidateResetCode(email);
      return res.status(400).json({
        message: "Codigo expirado. Solicite um novo codigo.",
      });
    }

    await clearResetCode(email);
    await auth.updateUser(user.uid, {password: novaSenha});

    return res.status(200).json({
      message: "Senha redefinida com sucesso.",
    });
  } catch (error) {
    logger.error("Erro ao redefinir senha.", error);
    return res.status(500).json({
      message: "Nao foi possivel redefinir a senha.",
    });
  }
});

export const api = onRequest(
  {region: "southamerica-east1"},
  app,
);

import {setGlobalOptions} from "firebase-functions";

setGlobalOptions({maxInstances: 10});

export * from "./startups";
