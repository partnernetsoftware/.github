const IV_BYTES = 12;

export async function deriveAesKey(secret: string): Promise<CryptoKey> {
  const material = new TextEncoder().encode(secret);
  const hash = await crypto.subtle.digest("SHA-256", material);
  return crypto.subtle.importKey("raw", hash, { name: "AES-GCM" }, false, [
    "encrypt",
    "decrypt",
  ]);
}

/** Encrypt JSON-serializable value; returns base64(iv || ciphertext). */
export async function encryptJson(
  key: CryptoKey,
  value: unknown,
): Promise<string> {
  const iv = crypto.getRandomValues(new Uint8Array(IV_BYTES));
  const plain = new TextEncoder().encode(JSON.stringify(value));
  const cipher = await crypto.subtle.encrypt({ name: "AES-GCM", iv }, key, plain);
  const out = new Uint8Array(iv.length + cipher.byteLength);
  out.set(iv, 0);
  out.set(new Uint8Array(cipher), iv.length);
  return btoa(String.fromCharCode(...out));
}

export async function decryptJson<T>(
  key: CryptoKey,
  blob: string,
): Promise<T> {
  const raw = Uint8Array.from(atob(blob), (c) => c.charCodeAt(0));
  const iv = raw.slice(0, IV_BYTES);
  const data = raw.slice(IV_BYTES);
  const plain = await crypto.subtle.decrypt({ name: "AES-GCM", iv }, key, data);
  return JSON.parse(new TextDecoder().decode(plain)) as T;
}

export function encryptionSecret(env: {
  ENCRYPTION_KEY?: string;
  VAULT_TOKEN: string;
}): string {
  return env.ENCRYPTION_KEY?.trim() || env.VAULT_TOKEN;
}
