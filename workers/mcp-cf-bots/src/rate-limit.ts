import { trimOpt } from "./config";

const WINDOW_SEC = 60;

function maxOps(env: Env): number {
  const raw = trimOpt(env.MEM_RATE_LIMIT_PER_MIN);
  if (!raw) {
    return 120;
  }
  const n = Number.parseInt(raw, 10);
  return Number.isFinite(n) && n > 0 ? n : 120;
}

/** Per-owner sliding window rate limit (KV). Used by mem_*, sess_*, and MCP reads. */
export async function checkOwnerRateLimit(
  env: Env,
  owner: string,
  op: string,
): Promise<void> {
  if (!env.TOKENS) {
    return;
  }
  const window = Math.floor(Date.now() / 1000 / WINDOW_SEC);
  const key = `rate:${owner}:${op}:${window}`;
  const raw = await env.TOKENS.get(key);
  const count = raw ? Number.parseInt(raw, 10) : 0;
  const limit = maxOps(env);
  if (count >= limit) {
    throw new Error(`rate limit exceeded for ${op} (${limit}/min)`);
  }
  await env.TOKENS.put(key, String(count + 1), { expirationTtl: WINDOW_SEC * 2 });
}

/** @deprecated Use checkOwnerRateLimit */
export const checkMemRateLimit = checkOwnerRateLimit;
