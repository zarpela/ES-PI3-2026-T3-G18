export function onlyNumbers(value: string): string {
  return value.replace(/\D+/g, "");
}

export function isValidEmail(value: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}

export function isValidCPF(value: string): boolean {
  const sanitized = onlyNumbers(value);

  if (sanitized.length !== 11 || /^(\d)\1{10}$/.test(sanitized)) {
    return false;
  }

  const digits = sanitized.split("").map(Number);

  const firstVerifier = calculateCpfVerifier(digits, 9);
  const secondVerifier = calculateCpfVerifier(digits, 10);

  return digits[9] === firstVerifier && digits[10] === secondVerifier;
}

function calculateCpfVerifier(digits: number[], length: number): number {
  const total = digits
    .slice(0, length)
    .reduce((sum, digit, index) => sum + digit * (length + 1 - index), 0);
  const remainder = (total * 10) % 11;

  return remainder === 10 ? 0 : remainder;
}
