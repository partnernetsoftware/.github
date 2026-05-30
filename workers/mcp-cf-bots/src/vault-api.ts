import { handleAdminRest } from "./admin-api";
import { effectiveOwner, type AuthContext } from "./auth";
import { readOwnerHeader } from "./config";
import { apiError } from "./http-util";
import type { SessionMeta } from "./kinds";
import { fetchRegistryEntries, registryStub } from "./registry-client";
import { registryEntryFromMeta } from "./registry-do";
import { sessionStub } from "./session-store";
import { validateKey } from "./validate";

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

export async function touchRegistry(
  env: Env,
  owner: string,
  site: string,
  profile: string,
  action: "upsert" | "remove",
  meta?: SessionMeta,
): Promise<void> {
  const stub = registryStub(env, owner);
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

export async function sessionPut(
  env: Env,
  owner: string,
  site: string,
  profile: string,
  body: Record<string, unknown>,
): Promise<Response> {
  const stub = sessionStub(env, owner, site, profile);
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
    const source = url.searchParams.get("source") ?? undefined;
    const tag = url.searchParams.get("tag") ?? undefined;
    return fetchRegistryEntries(env, owner, { source, tag });
  }

  const match = url.pathname.match(SESSION_RE);
  if (!match) {
    return apiError(404, "Not found");
  }

  const [, siteRaw, profileRaw] = match;
  const site = validateKey("site", siteRaw);
  const profile = validateKey("profile", profileRaw);
  const owner = ownerFromRequest(auth, env, url, request);
  const stub = sessionStub(env, owner, site, profile);

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

export { registryId, sessionStoreId } from "./session-store";
