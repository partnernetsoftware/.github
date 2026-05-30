import { trimOpt } from "./config";

function intOpt(raw: string | undefined, fallback: number): number {
  const v = trimOpt(raw);
  if (!v) {
    return fallback;
  }
  const n = Number.parseInt(v, 10);
  return Number.isFinite(n) && n > 0 ? n : fallback;
}

export function memChunkSize(env: Env): number {
  return intOpt(env.MEM_CHUNK_CHARS, 1500);
}

export function memMaxKeys(env: Env): number {
  return intOpt(env.MAX_MEM_KEYS, 2000);
}

export function memMaxBytes(env: Env): number {
  return intOpt(env.MAX_MEM_BYTES, 8_000_000);
}

export function memMaxChunkBytes(env: Env): number {
  return intOpt(env.MAX_MEM_CHUNK_BYTES, 32_000);
}

export function memEncryptAtRest(env: Env): boolean {
  const v = trimOpt(env.MEM_ENCRYPT)?.toLowerCase();
  return v === "1" || v === "true" || v === "yes";
}
