/**
 * Web Crypto + Workers runtime only (no Node/Bun APIs).
 * @see https://developers.cloudflare.com/workers/runtime-apis/web-crypto/
 */
const IV_BYTES = 12;

function bytesToBase64(bytes: Uint8Array): string {
  let binary = "";
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]!);
  }
  return btoa(binary);
}

function base64ToBytes(blob: string): Uint8Array {
  const binary = atob(blob);
  const out = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    out[i] = binary.charCodeAt(i);
  }
  return out;
}

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
  return bytesToBase64(out);
}

export async function decryptJson<T>(
  key: CryptoKey,
  blob: string,
): Promise<T> {
  const raw = base64ToBytes(blob);
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
