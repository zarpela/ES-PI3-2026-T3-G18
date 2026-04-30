/*
Autor: [COLOQUE SEU NOME COMPLETO]
RA: [COLOQUE SEU RA]
*/

import {NextFunction, Request, Response} from "express";
import {auth} from "../config/firebase";

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
    return res.status(401).json(buildErrorResponse(invalidTokenMessage));
  }
}
