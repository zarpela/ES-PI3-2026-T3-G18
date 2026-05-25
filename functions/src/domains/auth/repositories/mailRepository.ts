import * as logger from "firebase-functions/logger";
import nodemailer from "nodemailer";
import type {LocalMailConfig} from "../../../shared/types";
import {
  loadJsonFile,
  resolveFunctionsPath,
} from "../../../shared/utils";

type MailCredentials = {
  mailPass: string;
  mailUser: string;
};

function loadLocalMailConfig(): LocalMailConfig {
  return (
    loadJsonFile<LocalMailConfig>(
      resolveFunctionsPath("local-mail.config.json"),
    ) ?? {}
  );
}

function getMailCredentials(): MailCredentials | null {
  const localMailConfig = loadLocalMailConfig();
  const mailUser = process.env.MAIL_USER || localMailConfig.mailUser;
  const mailPass = process.env.MAIL_PASS || localMailConfig.mailPass;

  if (!mailUser || !mailPass) {
    return null;
  }

  return {
    mailUser,
    mailPass,
  };
}

async function sendMesclaEmail({
  html,
  subject,
  to,
}: {
  html: string;
  subject: string;
  to: string;
}): Promise<boolean> {
  const credentials = getMailCredentials();

  if (!credentials) {
    logger.warn(
      "MAIL_USER/MAIL_PASS nao configurados. O envio de e-mail nao foi realizado.",
    );
    return false;
  }

  const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 587,
    secure: false,
    auth: {
      user: credentials.mailUser,
      pass: credentials.mailPass,
    },
  });

  await transporter.sendMail({
    from: `"MesclaInvest" <${credentials.mailUser}>`,
    to,
    subject,
    html,
  });

  return true;
}

export async function sendPasswordResetEmail(
  to: string,
  code: string,
): Promise<boolean> {
  return sendMesclaEmail({
    to,
    subject: "Codigo de recuperacao de senha",
    html: `
      <h2>Recuperacao de senha</h2>
      <p>Use o codigo abaixo para redefinir sua senha:</p>
      <h1 style="letter-spacing:4px">${code}</h1>
      <p>Se voce nao fez essa solicitacao, ignore este email.</p>
    `,
  });
}

export async function sendLoginMfaEmail(
  to: string,
  code: string,
): Promise<boolean> {
  return sendMesclaEmail({
    to,
    subject: "Codigo de autenticacao multifator",
    html: `
      <h2>Autenticacao multifator</h2>
      <p>Use o codigo abaixo para concluir seu login no MesclaInvest:</p>
      <h1 style="letter-spacing:4px">${code}</h1>
      <p>Se voce nao tentou entrar na sua conta, altere sua senha.</p>
    `,
  });
}
