type ErrorLike = {
  code?: unknown;
  status?: unknown;
};

export class AppError extends Error {
  constructor(
    public readonly status: number,
    message: string,
    public readonly code?: string,
  ) {
    super(message);
    this.name = "AppError";
  }
}

export function createAppError(
  status: number,
  message: string,
  code?: string,
): AppError {
  return new AppError(status, message, code);
}

export function isAppError(error: unknown): error is AppError {
  return error instanceof AppError;
}

export function getErrorStatus(error: unknown, fallback = 400): number {
  const status = (error as ErrorLike).status;

  if (typeof status === "number") {
    return status;
  }

  const code = (error as ErrorLike).code;

  if (code === "auth/email-already-exists") {
    return 409;
  }

  return fallback;
}

export function getErrorMessage(error: unknown, fallback: string): string {
  if (error instanceof Error && error.message) {
    return error.message;
  }

  const code = (error as ErrorLike).code;

  if (code === "auth/email-already-exists") {
    return "Ja existe um usuario com esse email.";
  }

  if (code === "auth/invalid-email") {
    return "Informe um e-mail valido.";
  }

  if (code === "auth/invalid-password") {
    return "A senha deve ter pelo menos 8 caracteres.";
  }

  return fallback;
}
