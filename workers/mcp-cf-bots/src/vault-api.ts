import { handleAdminRest } from "./admin-api";
import { effectiveOwner, type AuthContext } from "./auth";
import { readOwnerHeader } from "./config";
import type { SessionMeta } from "./kinds";
import { registryEntryFromMeta } from "./registry-do";

const SESSION_RE = /^\/v1\/session\/([^/]+)\/([^/]+)\/?$/;

export function ownerFromRequest(
  auth: AuthContext,
  env: Env,
  url: URL,
  request: Request,
): string {
  return effectiveOwner(auth, env, {
    headerOwner: readOwnerHeader(request, env),
    queryOwner: url.searchParams.get("owner"),
  });
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

export async function vaultPut(
  env: Env,
  owner: string,
  site: string,
  profile: string,
  body: Record<string, unknown>,
): Promise<Response> {
  const id = env.SESSION_STORE.idFromName(vaultId(owner, site, profile));
  const stub = env.SESSION_STORE.get(id);
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

export async function handleVaultRest(
  request: Request,
  env: Env,
  url: URL,
  auth: AuthContext,
): Promise<Response> {
  const admin = await handleAdminRest(request, env, url, auth);
  if (admin) {
    return admin;
  }

  if (request.method === "GET" && url.pathname === "/v1/sessions") {
    const owner = ownerFromRequest(auth, env, url, request);
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
  const owner = ownerFromRequest(auth, env, url, request);
  const id = env.SESSION_STORE.idFromName(vaultId(owner, site, profile));
  const stub = env.SESSION_STORE.get(id);

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
