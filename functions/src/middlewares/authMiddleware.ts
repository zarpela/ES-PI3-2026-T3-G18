//feito por Abdallah
import {NextFunction, Request, Response} from "express";
import {auth} from "../shared/firebase";

const unauthorizedMessage = "Usuario nao autenticado.";
const invalidTokenMessage = "Token de autenticacao invalido.";

function buildErrorResponse(message: string) {
  return {
    ok: false,
    error: message,
    message,
  };
}

function extractBearerToken(authorizationHeader: string | undefined): string | null {
  if (!authorizationHeader) {
    return null;
  }

  const [scheme, token] = authorizationHeader.trim().split(/\s+/);

  if (scheme !== "Bearer" || !token) {
    return null;
  }

  return token;
}

function decodeUserIdFromEmulatorToken(idToken: string): string | null {
  if (process.env.FUNCTIONS_EMULATOR !== "true") {
    return null;
  }

  const [, payload] = idToken.split(".");

  if (!payload) {
    return null;
  }

  try {
    const decodedPayload = JSON.parse(
      Buffer.from(payload, "base64url").toString("utf8"),
    ) as {sub?: unknown; user_id?: unknown};
    const uid = String(decodedPayload.user_id ?? decodedPayload.sub ?? "")
      .trim();

    return uid || null;
  } catch (_error) {
    return null;
  }
}

export async function requireAuthenticatedUser(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  const idToken = extractBearerToken(req.headers.authorization);

  if (!idToken) {
    return res.status(401).json(buildErrorResponse(unauthorizedMessage));
  }

  try {
    const decodedToken = await auth.verifyIdToken(idToken, true);
    res.locals.authenticatedUserId = decodedToken.uid;

    return next();
  } catch (_error) {
    const emulatorUserId = decodeUserIdFromEmulatorToken(idToken);

    if (emulatorUserId) {
      res.locals.authenticatedUserId = emulatorUserId;
      return next();
    }

    return res.status(401).json(buildErrorResponse(invalidTokenMessage));
  }
}
