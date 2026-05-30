import { adminToolCall } from "./admin-api";
import { isAdmin, type AuthContext } from "./auth";
import { defaultSessionSource } from "./config";
import { SESSION_KINDS, type SessionKind } from "./kinds";
import { ownerForTool } from "./owner-scope";
import { fetchRegistryEntries } from "./registry-client";
import { metaFromArgs } from "./session-meta";
import { sessionStub } from "./session-store";
import { sessionPut, touchRegistry } from "./vault-api";
import { requireSiteProfile } from "./validate";

/** MCP `sess_*` / `auth_*` admin tool handlers. */
export async function sessToolCall(
  env: Env,
  name: string,
  args: Record<string, unknown>,
  auth: AuthContext,
  requestOwner: string,
): Promise<string> {
  if (name.startsWith("auth_")) {
    if (!isAdmin(auth)) {
      throw new Error("forbidden: admin token required");
    }
    return adminToolCall(env, name, args);
  }

  const owner = ownerForTool(auth, env, args, requestOwner);

  if (name === "sess_list") {
    const filters: { source?: string; tag?: string } = {};
    if (typeof args.source === "string" && args.source) {
      filters.source = args.source;
    }
    if (typeof args.tag === "string" && args.tag) {
      filters.tag = args.tag;
    }
    const res = await fetchRegistryEntries(env, owner, filters);
    return res.text();
  }

  const { site, profile } = requireSiteProfile(args);
  const stub = sessionStub(env, owner, site, profile);

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
    const meta = metaFromArgs(args);
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
    const res = await sessionPut(env, owner, site, profile, body);
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
    const meta = metaFromArgs(args);
    if (Object.keys(meta).length > 0) {
      body.meta = meta;
    }
    const res = await sessionPut(env, owner, site, profile, body);
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
