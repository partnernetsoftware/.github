/** Per-user API tokens (KV) + admin bearer (VAULT_TOKEN secret). */

import { trimOpt } from "./config";
import { safeEqual } from "./http-util";
import { validateOwnerId } from "./validate";

export type AuthContext =
  | { role: "admin" }
  | { role: "user"; owner: string; tokenId: string; label?: string };

export interface TokenRecord {
  id: string;
  owner: string;
  label?: string;
  created_at: string;
}

export interface TokenCreateResult {
  id: string;
  owner: string;
  label?: string;
  token: string;
  created_at: string;
}

const HASH_PREFIX = "h:";
const ID_PREFIX = "id:";
const OWNER_IDX_PREFIX = "owneridx:";

function tokenKey(hashHex: string): string {
  return `${HASH_PREFIX}${hashHex}`;
}

function idKey(id: string): string {
  return `${ID_PREFIX}${id}`;
}

function ownerIdxKey(owner: string): string {
  return `${OWNER_IDX_PREFIX}${owner}`;
}

async function sha256Hex(text: string): Promise<string> {
  const buf = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(text),
  );
  return [...new Uint8Array(buf)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function generateRawToken(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  let binary = "";
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]!);
  }
  const b64 = btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
  return `cfb_${b64}`;
}

function readBearer(request: Request): string | null {
  const header = request.headers.get("Authorization");
  if (!header?.startsWith("Bearer ")) {
    return null;
  }
  const token = header.slice("Bearer ".length).trim();
  return token.length > 0 ? token : null;
}

export async function authenticateRequest(
  request: Request,
  env: Env,
): Promise<AuthContext | null> {
  const bearer = readBearer(request);
  if (!bearer) {
    return null;
  }
  if (env.VAULT_TOKEN && safeEqual(bearer, env.VAULT_TOKEN)) {
    return { role: "admin" };
  }
  if (!env.TOKENS) {
    return null;
  }
  const hash = await sha256Hex(bearer);
  const raw = await env.TOKENS.get(tokenKey(hash));
  if (!raw) {
    return null;
  }
  try {
    const rec = JSON.parse(raw) as TokenRecord;
    if (!rec.owner || !rec.id) {
      return null;
    }
    return {
      role: "user",
      owner: rec.owner,
      tokenId: rec.id,
      label: rec.label,
    };
  } catch {
    return null;
  }
}

export function isAdmin(auth: AuthContext): boolean {
  return auth.role === "admin";
}

/** Resolve vault owner namespace for this request. */
export function effectiveOwner(
  auth: AuthContext,
  env: Env,
  opts?: {
    headerOwner?: string | null;
    queryOwner?: string | null;
    argOwner?: string | null;
  },
): string {
  if (auth.role === "user") {
    const bad =
      (trimOpt(opts?.argOwner ?? undefined) &&
        trimOpt(opts?.argOwner ?? undefined) !== auth.owner) ||
      (trimOpt(opts?.headerOwner ?? undefined) &&
        trimOpt(opts?.headerOwner ?? undefined) !== auth.owner) ||
      (trimOpt(opts?.queryOwner ?? undefined) &&
        trimOpt(opts?.queryOwner ?? undefined) !== auth.owner);
    if (bad) {
      throw new Error("forbidden: cannot access another owner's vault");
    }
    return auth.owner;
  }

  const fromArg = trimOpt(opts?.argOwner ?? undefined);
  if (fromArg) {
    return fromArg;
  }
  const fromHeader = trimOpt(opts?.headerOwner ?? undefined);
  if (fromHeader) {
    return fromHeader;
  }
  const fromQuery = trimOpt(opts?.queryOwner ?? undefined);
  if (fromQuery) {
    return fromQuery;
  }
  const fromEnv = trimOpt(env.DEFAULT_OWNER);
  if (fromEnv) {
    return fromEnv;
  }
  throw new Error(
    "owner required: ?owner=, owner header, tool arg, or DEFAULT_OWNER (admin only)",
  );
}

export async function createUserToken(
  env: Env,
  owner: string,
  label?: string,
): Promise<TokenCreateResult> {
  if (!env.TOKENS) {
    throw new Error("TOKENS KV binding is not configured");
  }
  const o = validateOwnerId(owner);
  const id = crypto.randomUUID();
  const token = generateRawToken();
  const created_at = new Date().toISOString();
  const rec: TokenRecord = { id, owner: o, label: label?.trim() || undefined, created_at };
  const hash = await sha256Hex(token);
  await env.TOKENS.put(tokenKey(hash), JSON.stringify(rec));
  await env.TOKENS.put(idKey(id), hash);

  const idxRaw = await env.TOKENS.get(ownerIdxKey(o));
  let ids: string[] = [];
  if (idxRaw) {
    try {
      ids = JSON.parse(idxRaw) as string[];
    } catch {
      ids = [];
    }
  }
  if (!ids.includes(id)) {
    ids.push(id);
  }
  await env.TOKENS.put(ownerIdxKey(o), JSON.stringify(ids));

  return { id, owner: o, label: rec.label, token, created_at };
}

export async function revokeUserToken(env: Env, tokenId: string): Promise<boolean> {
  if (!env.TOKENS) {
    throw new Error("TOKENS KV binding is not configured");
  }
  const id = tokenId.trim();
  const hash = await env.TOKENS.get(idKey(id));
  if (!hash) {
    return false;
  }
  const raw = await env.TOKENS.get(tokenKey(hash));
  if (raw) {
    try {
      const rec = JSON.parse(raw) as TokenRecord;
      const idxRaw = await env.TOKENS.get(ownerIdxKey(rec.owner));
      if (idxRaw) {
        const ids = (JSON.parse(idxRaw) as string[]).filter((x) => x !== id);
        await env.TOKENS.put(ownerIdxKey(rec.owner), JSON.stringify(ids));
      }
    } catch {
      /* ignore */
    }
  }
  await env.TOKENS.delete(tokenKey(hash));
  await env.TOKENS.delete(idKey(id));
  return true;
}

export async function listUserTokens(
  env: Env,
  ownerFilter?: string,
): Promise<TokenRecord[]> {
  if (!env.TOKENS) {
    throw new Error("TOKENS KV binding is not configured");
  }
  const filter = ownerFilter?.trim();
  const out: TokenRecord[] = [];

  if (filter) {
    const idxRaw = await env.TOKENS.get(ownerIdxKey(filter));
    if (!idxRaw) {
      return [];
    }
    const ids = JSON.parse(idxRaw) as string[];
    for (const id of ids) {
      const hash = await env.TOKENS.get(idKey(id));
      if (!hash) {
        continue;
      }
      const raw = await env.TOKENS.get(tokenKey(hash));
      if (raw) {
        out.push(JSON.parse(raw) as TokenRecord);
      }
    }
    return out;
  }

  const listed = await env.TOKENS.list({ prefix: OWNER_IDX_PREFIX });
  for (const key of listed.keys) {
    const o = key.name.slice(OWNER_IDX_PREFIX.length);
    out.push(...(await listUserTokens(env, o)));
  }
  return out;
}
