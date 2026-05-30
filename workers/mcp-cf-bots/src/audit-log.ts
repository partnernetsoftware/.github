import type { AuthContext } from "./auth";

const AUDIT_LOG_KEY = "audit:recent";
const MAX_ENTRIES = 100;

export type AuditEntry = {
  at: string;
  action: string;
  actor: "admin" | "user";
  owner?: string;
  token_id?: string;
  detail?: Record<string, unknown>;
};

export async function auditLog(
  env: Env,
  auth: AuthContext,
  action: string,
  detail?: Record<string, unknown>,
): Promise<void> {
  if (!env.TOKENS) {
    return;
  }
  const entry: AuditEntry = {
    at: new Date().toISOString(),
    action,
    actor: auth.role,
    ...(auth.role === "user"
      ? { owner: auth.owner, token_id: auth.tokenId }
      : {}),
    detail,
  };
  let entries: AuditEntry[] = [];
  const raw = await env.TOKENS.get(AUDIT_LOG_KEY);
  if (raw) {
    try {
      entries = JSON.parse(raw) as AuditEntry[];
    } catch {
      entries = [];
    }
  }
  entries.unshift(entry);
  if (entries.length > MAX_ENTRIES) {
    entries = entries.slice(0, MAX_ENTRIES);
  }
  await env.TOKENS.put(AUDIT_LOG_KEY, JSON.stringify(entries), {
    expirationTtl: 60 * 60 * 24 * 90,
  });
}

export async function listAuditLog(env: Env, limit = 50): Promise<AuditEntry[]> {
  if (!env.TOKENS) {
    return [];
  }
  const raw = await env.TOKENS.get(AUDIT_LOG_KEY);
  if (!raw) {
    return [];
  }
  try {
    const entries = JSON.parse(raw) as AuditEntry[];
    return entries.slice(0, limit);
  } catch {
    return [];
  }
}
