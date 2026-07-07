import { decryptJson, deriveAesKey, encryptJson, encryptionSecret } from "./crypto";
import { memEncryptAtRest } from "./mem-config";

const ENC_PREFIX = "enc:";

export async function maybeEncryptContent(
  env: Env,
  plain: string,
): Promise<string> {
  if (!memEncryptAtRest(env)) {
    return plain;
  }
  const key = await deriveAesKey(encryptionSecret(env));
  const blob = await encryptJson(key, plain);
  return `${ENC_PREFIX}${blob}`;
}

export async function maybeDecryptContent(
  env: Env,
  stored: string,
): Promise<string> {
  if (!stored.startsWith(ENC_PREFIX)) {
    return stored;
  }
  const key = await deriveAesKey(encryptionSecret(env));
  return decryptJson<string>(key, stored.slice(ENC_PREFIX.length));
}
