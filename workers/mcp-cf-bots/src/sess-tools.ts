import { adminToolCall } from "./admin-api";
import {
  effectiveOwner,
  isAdmin,
  type AuthContext,
} from "./auth";
import { defaultSessionSource } from "./config";
import { SESSION_KINDS, type SessionKind, type SessionMeta } from "./kinds";
import {
  registryId,
  touchRegistry,
  vaultId,
  vaultPut,
} from "./vault-api";

function resolveToolOwner(
  auth: AuthContext,
  env: Env,
  args: Record<string, unknown>,
  requestOwner: string,
): string {
  return effectiveOwner(auth, env, {
    argOwner: String(args.owner ?? "").trim() || null,
    headerOwner: requestOwner,
  });
}

function buildMetaFromArgs(args: Record<string, unknown>): Partial<SessionMeta> {
  const meta: Partial<SessionMeta> = {};
  if (typeof args.expires_at === "string" && args.expires_at) {
    meta.expires_at = args.expires_at;
  }
  if (typeof args.label === "string" && args.label) {
    meta.label = args.label;
  }
  if (typeof args.source === "string" && args.source) {
    meta.source = args.source;
  }
  if (typeof args.notes === "string" && args.notes) {
    meta.notes = args.notes;
  }
  if (Array.isArray(args.tags)) {
    meta.tags = args.tags.map(String);
  }
  return meta;
}

/** MCP `sess_*` tool handlers. */
export async function vaultToolCall(
  env: Env,
  name: string,
  args: Record<string, unknown>,
  auth: AuthContext,
  requestOwner: string,
): Promise<string> {
  if (name.startsWith("auth_token_")) {
    if (!isAdmin(auth)) {
      throw new Error("forbidden: admin token required");
    }
    return adminToolCall(env, name, args);
  }

  const owner = resolveToolOwner(auth, env, args, requestOwner);

  if (name === "sess_list") {
    const regUrl = new URL("https://registry.internal/entries");
    if (typeof args.source === "string" && args.source) {
      regUrl.searchParams.set("source", args.source);
    }
    if (typeof args.tag === "string" && args.tag) {
      regUrl.searchParams.set("tag", args.tag);
    }
    const res = await env.REGISTRY.get(
      env.REGISTRY.idFromName(registryId(owner)),
    ).fetch(regUrl.toString());
    return res.text();
  }

  const site = String(args.site ?? "");
  const profile = String(args.profile ?? "");
  if (!site || !profile) {
    throw new Error("site and profile are required");
  }

  const id = env.SESSION_STORE.idFromName(vaultId(owner, site, profile));
  const stub = env.SESSION_STORE.get(id);

  if (name === "sess_save") {
    const body: Record<string, unknown> = {};
    if (args.storage_state !== undefined) {
      body.storage_state = args.storage_state;
    }
    if (args.oauth !== undefined) {
      body.oauth = args.oauth;
    }
    if (args.cookies !== undefined) {
      body.cookies = args.cookies;
    }
    if (args.config !== undefined) {
      body.config = args.config;
    }
    const meta = buildMetaFromArgs(args);
    if (!meta.source) {
      meta.source = defaultSessionSource(env);
    }
    if (Object.keys(meta).length > 0) {
      body.meta = meta;
    }
    if (Object.keys(body).length === 0) {
      throw new Error(
        "provide at least one of storage_state, oauth, cookies, config",
      );
    }
    const res = await vaultPut(env, owner, site, profile, body);
    return res.text();
  }

  if (name === "sess_load") {
    const res = await stub.fetch("https://vault.internal/", { method: "GET" });
    if (res.status === 410) {
      throw new Error("Session expired — re-login via Take Control and save again");
    }
    const text = await res.text();
    if (!args.include_oauth && !args.include_cookies && !args.include_config) {
      try {
        const parsed = JSON.parse(text) as Record<string, unknown>;
        const slim: Record<string, unknown> = { meta: parsed.meta };
        if (parsed.storage_state !== undefined) {
          slim.storage_state = parsed.storage_state;
        }
        return JSON.stringify(slim);
      } catch {
        return text;
      }
    }
    return text;
  }

  if (name === "sess_meta") {
    const res = await stub.fetch("https://vault.internal/?meta_only=1", {
      method: "GET",
    });
    return res.text();
  }

  if (name === "sess_put") {
    const kind = String(args.kind ?? "");
    if (!SESSION_KINDS.includes(kind as SessionKind)) {
      throw new Error(`invalid kind: ${kind}`);
    }
    const body: Record<string, unknown> = { [kind]: args.data };
    const meta = buildMetaFromArgs(args);
    if (Object.keys(meta).length > 0) {
      body.meta = meta;
    }
    const res = await vaultPut(env, owner, site, profile, body);
    return res.text();
  }

  if (name === "sess_get") {
    const kind = args.kind;
    const q =
      typeof kind === "string" && kind
        ? `?kind=${encodeURIComponent(kind)}`
        : "";
    const res = await stub.fetch(`https://vault.internal/${q}`, {
      method: "GET",
    });
    if (res.status === 410) {
      throw new Error("Session expired");
    }
    return res.text();
  }

  if (name === "sess_delete") {
    const res = await stub.fetch("https://vault.internal/", {
      method: "DELETE",
    });
    if (res.ok) {
      await touchRegistry(env, owner, site, profile, "remove");
    }
    return res.text();
  }

  throw new Error(`Unknown tool: ${name}`);
}
