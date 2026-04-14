import * as functions from "firebase-functions";
import express from "express";
import fs from "fs";
import nodemailer from "nodemailer";
import path from "path";

type MockUser = {
  email: string;
  senha: string;
  verificationCode?: string;
};

type LocalMailConfig = {
  mailUser?: string;
  mailPass?: string;
  testUsers?: Array<{
    email: string;
    senha: string;
  }>;
};

const app = express();

app.use(express.json());

function loadJsonFile<T>(fileName: string): T | undefined {
  const configPath = path.resolve(__dirname, fileName);

  if (!fs.existsSync(configPath)) {
    return undefined;
  }

  try {
    const config = fs.readFileSync(configPath, "utf8");
    return JSON.parse(config) as T;
  } catch (error) {
    functions.logger.error(
      `Nao foi possivel ler ${fileName}.`,
      error,
    );
    return undefined;
  }
}

function loadLocalMailConfig(): LocalMailConfig {
  return loadJsonFile<LocalMailConfig>("../local-mail.config.json") ?? {};
}

const defaultUsers: MockUser[] = [
  {email: "admin@test.com", senha: "123"},
  {email: "abdallahborges@gmail.com", senha: "123"},
];

const localMailConfig = loadLocalMailConfig();
const configuredUsers = (
  loadJsonFile<Array<{email: string; senha: string}>>(
    "../registered-users.local.json",
  ) ??
  loadJsonFile<Array<{email: string; senha: string}>>(
    "../registered-users.json",
  ) ??
  localMailConfig.testUsers ??
  defaultUsers).map((user) => ({
  email: user.email.trim().toLowerCase(),
  senha: user.senha,
}));

const users = new Map<string, MockUser>(
  configuredUsers.map((user) => [user.email, user]),
);

function findUser(identifier?: string): MockUser | undefined {
  if (!identifier) {
    return undefined;
  }

  const normalizedIdentifier = String(identifier).trim().toLowerCase();

  return users.get(normalizedIdentifier);
}

function generateVerificationCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

async function sendPasswordResetEmail(
  to: string,
  code: string,
): Promise<boolean> {
  const mailUser = process.env.MAIL_USER || localMailConfig.mailUser;
  const mailPass = process.env.MAIL_PASS || localMailConfig.mailPass;

  if (!mailUser || !mailPass) {
    functions.logger.warn(
      "MAIL_USER/MAIL_PASS nao configurados. " +
      "Preencha functions/local-mail.config.json para envio real.",
      {to, code},
    );
    return false;
  }

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: mailUser,
      pass: mailPass,
    },
  });

  await transporter.sendMail({
    from: `"MesclaInvest" <${mailUser}>`,
    to,
    subject: "Recuperacao de Senha",
    html: `
      <h1>Codigo de Recuperacao de Senha</h1>
      <p>Ola,</p>
      <p>Use o codigo abaixo para redefinir sua senha:</p>
      <h2><strong>${code}</strong></h2>
      <p>Se voce nao solicitou esta recuperacao, ignore este email.</p>
      <p>Atenciosamente,<br>Equipe MesclaInvest</p>
    `,
  });

  return true;
}

function shouldReturnCodeForTesting(): boolean {
  return process.env.FUNCTIONS_EMULATOR === "true";
}

app.post("/login", (req, res) => {
  const identifier = String(req.body.email ?? req.body.identifier ?? "")
    .trim()
    .toLowerCase();
  const senha = String(req.body.senha ?? "");
  const user = findUser(identifier);

  if (user && user.senha === senha) {
    return res.json({message: "Login ok"});
  }

  return res.status(401).json({error: "Credenciais invalidas"});
});

app.post("/forgot-password", async (req, res) => {
  const identifier = String(req.body.identifier ?? req.body.email ?? "")
    .trim()
    .toLowerCase();
  const user = findUser(identifier);

  if (!identifier) {
    return res.status(400).json({message: "Identifier e obrigatorio."});
  }

  if (!user) {
    return res.status(404).json({message: "Usuario nao encontrado."});
  }

  const verificationCode = generateVerificationCode();
  user.verificationCode = verificationCode;
  users.set(user.email, user);

  try {
    const emailSent = await sendPasswordResetEmail(user.email, verificationCode);

    return res.status(200).json({
      email: user.email,
      message: emailSent ?
        "Codigo de recuperacao enviado com sucesso." :
        "Codigo gerado para teste local.",
      ...(shouldReturnCodeForTesting() ? {code: verificationCode} : {}),
    });
  } catch (error) {
    functions.logger.error("Erro ao enviar e-mail de recuperacao.", error);
    return res.status(500).json({
      message: "Nao foi possivel enviar o e-mail de recuperacao de senha.",
    });
  }
});

app.post("/reset-password", (req, res) => {
  const email = String(req.body.email ?? "").trim().toLowerCase();
  const novaSenha = String(req.body.novaSenha ?? "");
  const code = req.body.code == null ? "" : String(req.body.code).trim();
  const user = findUser(email);

  if (!email || !novaSenha) {
    return res.status(400).json({
      message: "Email e novaSenha sao obrigatorios.",
    });
  }

  if (!user) {
    return res.status(404).json({message: "Usuario nao encontrado."});
  }

  if (novaSenha.length < 6) {
    return res.status(400).json({
      message: "A senha deve ter pelo menos 6 caracteres.",
    });
  }

  if (user.senha === novaSenha) {
    return res.status(400).json({
      message: "A nova senha nao pode ser igual a senha anterior.",
    });
  }

  if (code && user.verificationCode !== code) {
    return res.status(400).json({message: "Codigo de verificacao invalido."});
  }

  user.senha = novaSenha;
  user.verificationCode = undefined;
  users.set(user.email, user);

  return res.status(200).json({message: "Senha redefinida com sucesso."});
});

export const api = functions.https.onRequest(app);
