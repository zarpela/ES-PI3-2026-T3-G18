import * as logger from "firebase-functions/logger";
import nodemailer from "nodemailer";
import type {LocalMailConfig} from "../../../shared/types";
import {
  loadJsonFile,
  resolveFunctionsPath,
} from "../../../shared/utils";

function loadLocalMailConfig(): LocalMailConfig {
  return (
    loadJsonFile<LocalMailConfig>(
      resolveFunctionsPath("local-mail.config.json"),
    ) ?? {}
  );
}

export async function sendPasswordResetEmail(
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
