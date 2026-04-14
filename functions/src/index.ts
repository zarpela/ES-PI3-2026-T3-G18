import * as functions from "firebase-functions";
import express from "express";
import fs from "fs";
import path from "path";

// eslint-disable-next-line @typescript-eslint/no-var-requires
const nodemailer = require("nodemailer");

type StoredUser = {
  name?: string;
  email: string;
  senha: string;
  telefone?: string;
  cpf?: string;
  verificationCode?: string;
  verificationCodeExpiresAt?: string;
};

type LocalMailConfig = {
  mailUser?: string;
  mailPass?: string;
};

const app = express();
const usersFilePath = path.resolve(__dirname, "../registered-users.local.json");

app.use(express.json());
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept",
  );
  res.header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");

  if (req.method === "OPTIONS") {
    return res.status(204).send("");
  }

  next();
  return;
});

function loadJsonFile<T>(fileName: string): T | undefined {
  const filePath = path.resolve(__dirname, fileName);

  if (!fs.existsSync(filePath)) {
    return undefined;
  }

  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8")) as T;
  } catch (error) {
    functions.logger.error(`Nao foi possivel ler ${fileName}.`, error);
    return undefined;
  }
}

function loadLocalMailConfig(): LocalMailConfig {
  return loadJsonFile<LocalMailConfig>("../local-mail.config.json") ?? {};
}

function normalizeEmail(value: string): string {
  return value.trim().toLowerCase();
}

function ensureUsersFile(): void {
  if (!fs.existsSync(usersFilePath)) {
    const initialUsers: StoredUser[] = [
      {
        name: "Abdallah Borges",
        email: "abdallahborges@gmail.com",
        senha: "123",
      },
    ];

    fs.writeFileSync(usersFilePath, JSON.stringify(initialUsers, null, 2));
  }
}

function readUsers(): StoredUser[] {
  ensureUsersFile();

  try {
    const contents = fs.readFileSync(usersFilePath, "utf8");
    const users = JSON.parse(contents) as StoredUser[];
    return users.map((user) => ({
      ...user,
      email: normalizeEmail(user.email),
    }));
  } catch (error) {
    functions.logger.error("Nao foi possivel ler registered-users.local.json.", error);
    return [];
  }
}

function writeUsers(users: StoredUser[]): void {
  fs.writeFileSync(usersFilePath, JSON.stringify(users, null, 2));
}

function findUser(email: string): StoredUser | undefined {
  const normalizedEmail = normalizeEmail(email);
  return readUsers().find((user) => normalizeEmail(user.email) === normalizedEmail);
}

function generateVerificationCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function shouldReturnCodeForTesting(): boolean {
  return process.env.FUNCTIONS_EMULATOR === "true";
}

async function sendPasswordResetEmail(
  to: string,
  code: string,
): Promise<boolean> {
  const localMailConfig = loadLocalMailConfig();
  const mailUser = process.env.MAIL_USER || localMailConfig.mailUser;
  const mailPass = process.env.MAIL_PASS || localMailConfig.mailPass;

  if (!mailUser || !mailPass) {
    functions.logger.warn(
      "MAIL_USER/MAIL_PASS nao configurados. Preencha functions/local-mail.config.json.",
      {to, code},
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
  return res.json({message: "API de autenticacao local ativa."});
});

app.post("/register", (req, res) => {
  const name = String(req.body.name ?? "").trim();
  const telefone = String(req.body.telefone ?? "").trim();
  const email = normalizeEmail(String(req.body.email ?? ""));
  const senha = String(req.body.senha ?? "");
  const cpf = String(req.body.cpf ?? "").trim();

  if (!name || !telefone || !email || !senha || !cpf) {
    return res.status(400).json({
      message: "name, telefone, email, senha e cpf sao obrigatorios.",
    });
  }

  if (senha.length < 6) {
    return res.status(400).json({
      message: "A senha deve ter pelo menos 6 caracteres.",
    });
  }

  const users = readUsers();
  const existingUser = users.find((user) => user.email === email);

  if (existingUser) {
    return res.status(409).json({
      message: "Ja existe um usuario com esse email.",
    });
  }

  const newUser: StoredUser = {
    name,
    telefone,
    email,
    senha,
    cpf,
  };

  users.push(newUser);
  writeUsers(users);

  return res.status(201).json({
    message: "Usuario cadastrado com sucesso.",
    user: {
      name,
      telefone,
      email,
      cpf,
    },
  });
});

app.post("/login", (req, res) => {
  const email = normalizeEmail(String(req.body.email ?? req.body.identifier ?? ""));
  const senha = String(req.body.senha ?? "");
  const user = findUser(email);

  if (!email || !senha) {
    return res.status(400).json({
      message: "email e senha sao obrigatorios.",
    });
  }

  if (!user || user.senha !== senha) {
    return res.status(401).json({
      message: "Credenciais invalidas.",
    });
  }

  return res.status(200).json({
    message: "Login realizado com sucesso.",
    user: {
      name: user.name,
      email: user.email,
    },
  });
});

app.post("/forgot-password", async (req, res) => {
  const email = normalizeEmail(String(req.body.identifier ?? req.body.email ?? ""));

  if (!email) {
    return res.status(400).json({
      message: "identifier e obrigatorio.",
    });
  }

  const users = readUsers();
  const userIndex = users.findIndex((user) => user.email === email);

  if (userIndex < 0) {
    return res.status(404).json({
      message: "Usuario nao encontrado.",
    });
  }

  const code = generateVerificationCode();
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000).toISOString();

  users[userIndex] = {
    ...users[userIndex],
    verificationCode: code,
    verificationCodeExpiresAt: expiresAt,
  };
  writeUsers(users);

  try {
    const emailSent = await sendPasswordResetEmail(email, code);

    return res.status(200).json({
      message: emailSent ?
        "Codigo de verificacao enviado por e-mail." :
        "Codigo gerado para teste local.",
      email,
      ...(shouldReturnCodeForTesting() ? {code} : {}),
    });
  } catch (error) {
    functions.logger.error("Erro ao enviar e-mail de recuperacao.", error);
    return res.status(500).json({
      message: "Nao foi possivel enviar o e-mail de recuperacao de senha.",
      ...(shouldReturnCodeForTesting() ? {code} : {}),
    });
  }
});

app.post("/verify-reset-code", (req, res) => {
  const email = normalizeEmail(String(req.body.email ?? ""));
  const code = String(req.body.code ?? "").trim();

  if (!email || !code) {
    return res.status(400).json({
      message: "email e code sao obrigatorios.",
    });
  }

  const user = findUser(email);

  if (!user) {
    return res.status(404).json({
      message: "Usuario nao encontrado.",
    });
  }

  if (!user.verificationCode || user.verificationCode !== code) {
    return res.status(400).json({
      message: "Codigo de verificacao invalido.",
    });
  }

  if (
    user.verificationCodeExpiresAt &&
    new Date(user.verificationCodeExpiresAt).getTime() < Date.now()
  ) {
    return res.status(400).json({
      message: "Codigo expirado. Solicite um novo codigo.",
    });
  }

  return res.status(200).json({
    message: "Codigo validado com sucesso.",
  });
});

app.post("/reset-password", (req, res) => {
  const email = normalizeEmail(String(req.body.email ?? ""));
  const novaSenha = String(req.body.novaSenha ?? "");
  const code = String(req.body.code ?? "").trim();

  if (!email || !novaSenha || !code) {
    return res.status(400).json({
      message: "email, novaSenha e code sao obrigatorios.",
    });
  }

  if (novaSenha.length < 6) {
    return res.status(400).json({
      message: "A senha deve ter pelo menos 6 caracteres.",
    });
  }

  const users = readUsers();
  const userIndex = users.findIndex((user) => user.email === email);

  if (userIndex < 0) {
    return res.status(404).json({
      message: "Usuario nao encontrado.",
    });
  }

  const user = users[userIndex];

  if (!user.verificationCode || user.verificationCode !== code) {
    return res.status(400).json({
      message: "Codigo de verificacao invalido.",
    });
  }

  if (
    user.verificationCodeExpiresAt &&
    new Date(user.verificationCodeExpiresAt).getTime() < Date.now()
  ) {
    return res.status(400).json({
      message: "Codigo expirado. Solicite um novo codigo.",
    });
  }

  users[userIndex] = {
    ...user,
    senha: novaSenha,
    verificationCode: undefined,
    verificationCodeExpiresAt: undefined,
  };

  writeUsers(users);

  return res.status(200).json({
    message: "Senha redefinida com sucesso.",
  });
});

export const api = functions.https.onRequest(app);
