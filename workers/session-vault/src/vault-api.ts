import {
  SESSION_KINDS,
  type SessionKind,
  type SessionMeta,
} from "./kinds";
import { registryEntryFromMeta } from "./registry-do";

const SESSION_RE = /^\/v1\/session\/([^/]+)\/([^/]+)\/?$/;

export function ownerFromRequest(url: URL, fallback = "default"): string {
  const owner = url.searchParams.get("owner")?.trim();
  return owner && owner.length > 0 ? owner : fallback;
}

export function vaultId(owner: string, site: string, profile: string): string {
  return `vault/${owner}/${site}/${profile}`;
}

export function registryId(owner: string): string {
  return `registry/${owner}`;
}

export async function touchRegistry(
  env: Env,
  owner: string,
  site: string,
  profile: string,
  action: "upsert" | "remove",
  meta?: SessionMeta,
): Promise<void> {
  const id = env.REGISTRY.idFromName(registryId(owner));
  const stub = env.REGISTRY.get(id);
  const path = action === "upsert" ? "/upsert" : "/remove";
  const body =
    action === "upsert"
      ? JSON.stringify(
          meta
            ? registryEntryFromMeta(site, profile, meta)
            : {
                site,
                profile,
                updated_at: new Date().toISOString(),
              },
        )
      : JSON.stringify({ site, profile });
  await stub.fetch(`https://registry.internal${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body,
  });
}

export async function handleVaultRest(
  request: Request,
  env: Env,
  url: URL,
): Promise<Response> {
  const defaultOwner = env.DEFAULT_OWNER?.trim() || "default";

  if (request.method === "GET" && url.pathname === "/v1/sessions") {
    const owner = ownerFromRequest(url, defaultOwner);
    const id = env.REGISTRY.idFromName(registryId(owner));
    const stub = env.REGISTRY.get(id);
    const regUrl = new URL("https://registry.internal/entries");
    const source = url.searchParams.get("source");
    const tag = url.searchParams.get("tag");
    if (source) {
      regUrl.searchParams.set("source", source);
    }
    if (tag) {
      regUrl.searchParams.set("tag", tag);
    }
    return stub.fetch(regUrl.toString());
  }

  const match = url.pathname.match(SESSION_RE);
  if (!match) {
    return Response.json({ error: "Not found" }, { status: 404 });
  }

  const [, site, profile] = match;
  const owner = ownerFromRequest(url, defaultOwner);
  const id = env.SESSION_VAULT.idFromName(vaultId(owner, site, profile));
  const stub = env.SESSION_VAULT.get(id);

  const doUrl = new URL(request.url);
  doUrl.pathname = "/";
  const doRequest = new Request(doUrl.toString(), {
    method: request.method,
    headers: request.headers,
    body:
      request.method === "PUT" || request.method === "POST"
        ? request.body
        : undefined,
  });

  const response = await stub.fetch(doRequest);

  if (response.ok) {
    if (request.method === "PUT") {
      let meta: SessionMeta | undefined;
      try {
        const json = (await response.clone().json()) as { meta?: SessionMeta };
        meta = json.meta;
      } catch {
        /* ignore */
      }
      await touchRegistry(env, owner, site, profile, "upsert", meta);
    } else if (request.method === "DELETE") {
      await touchRegistry(env, owner, site, profile, "remove");
    }
  }

  return response;
}

function resolveOwner(args: Record<string, unknown>, defaultOwner: string): string {
  const owner = String(args.owner ?? "").trim();
  return owner || defaultOwner;
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

async function vaultPut(
  env: Env,
  owner: string,
  site: string,
  profile: string,
  body: Record<string, unknown>,
): Promise<Response> {
  const id = env.SESSION_VAULT.idFromName(vaultId(owner, site, profile));
  const stub = env.SESSION_VAULT.get(id);
  const res = await stub.fetch("https://vault.internal/", {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (res.ok) {
    try {
      const json = (await res.clone().json()) as { meta?: SessionMeta };
      await touchRegistry(env, owner, site, profile, "upsert", json.meta);
    } catch {
      await touchRegistry(env, owner, site, profile, "upsert");
    }
  }
  return res;
}

/** MCP tool handlers — same semantics as products/mcp_cf_bots_mcp.py */
export async function vaultToolCall(
  env: Env,
  _baseUrl: string,
  name: string,
  args: Record<string, unknown>,
  defaultOwner = "default",
): Promise<string> {
  const owner = resolveOwner(args, defaultOwner);

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

  const id = env.SESSION_VAULT.idFromName(vaultId(owner, site, profile));
  const stub = env.SESSION_VAULT.get(id);

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
      meta.source = "browser-use";
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
    const kinds: string[] = [];
    if (args.include_oauth === true) {
      kinds.push("oauth");
    }
    if (args.include_cookies === true) {
      kinds.push("cookies");
    }
    if (args.include_config === true) {
      kinds.push("config");
    }
    const q = new URL("https://vault.internal/");
    if (kinds.length > 0) {
      /* load specific kinds only — multiple GET not supported; fetch all */
    }
    const res = await stub.fetch(q.toString(), { method: "GET" });
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
