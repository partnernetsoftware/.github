import { trimOpt } from "./config";

const KEY_RE = /^[a-zA-Z0-9][a-zA-Z0-9._-]{0,127}$/;

export function maxBodyBytes(env: Env): number {
  const raw = trimOpt(env.MAX_BODY_BYTES);
  if (!raw) {
    return 2_000_000;
  }
  const n = Number.parseInt(raw, 10);
  return Number.isFinite(n) && n > 0 ? n : 2_000_000;
}

export function assertBodySize(contentLength: string | null, env: Env): void {
  if (!contentLength) {
    return;
  }
  const len = Number.parseInt(contentLength, 10);
  if (Number.isFinite(len) && len > maxBodyBytes(env)) {
    throw new Error(`payload too large (max ${maxBodyBytes(env)} bytes)`);
  }
}

export function validateKey(name: string, value: string): string {
  const v = value.trim();
  if (!v || !KEY_RE.test(v)) {
    throw new Error(`invalid ${name}: use 1-128 chars [a-zA-Z0-9._-]`);
  }
  return v;
}

export function validateOwnerId(owner: string): string {
  const v = owner.trim();
  if (!v || v.length > 64 || !/^[a-zA-Z0-9][a-zA-Z0-9._-]*$/.test(v)) {
    throw new Error("invalid owner id");
  }
  return v;
}

export function assertProdEnv(env: Env): void {
  if (!trimOpt(env.VAULT_TOKEN)) {
    throw new Error("VAULT_TOKEN secret is not configured");
  }
  if (!env.TOKENS) {
    throw new Error("TOKENS KV binding is not configured");
  }
  if (!env.SESSION_STORE || !env.REGISTRY) {
    throw new Error("Durable Object bindings missing");
  }
}
