export { SessionVaultDO } from "./session-vault-do";
export { RegistryDO } from "./registry-do";

const SESSION_RE = /^\/v1\/session\/([^/]+)\/([^/]+)\/?$/;

function jsonError(status: number, message: string): Response {
  return Response.json({ error: message }, { status });
}

function authorize(request: Request, env: Env): boolean {
  const header = request.headers.get("Authorization");
  if (!header?.startsWith("Bearer ")) {
    return false;
  }
  const token = header.slice("Bearer ".length).trim();
  return token.length > 0 && token === env.VAULT_TOKEN;
}

function ownerFromRequest(url: URL): string {
  const owner = url.searchParams.get("owner")?.trim();
  return owner && owner.length > 0 ? owner : "default";
}

function vaultId(owner: string, site: string, profile: string): string {
  return `vault/${owner}/${site}/${profile}`;
}

function registryId(owner: string): string {
  return `registry/${owner}`;
}

async function touchRegistry(
  env: Env,
  owner: string,
  site: string,
  profile: string,
  action: "upsert" | "remove",
): Promise<void> {
  const id = env.REGISTRY.idFromName(registryId(owner));
  const stub = env.REGISTRY.get(id);
  const path = action === "upsert" ? "/upsert" : "/remove";
  const body =
    action === "upsert"
      ? JSON.stringify({
          site,
          profile,
          updated_at: new Date().toISOString(),
        })
      : JSON.stringify({ site, profile });
  await stub.fetch(`https://registry.internal${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body,
  });
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (!authorize(request, env)) {
      return jsonError(401, "Unauthorized");
    }

    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/v1/sessions") {
      const owner = ownerFromRequest(url);
      const id = env.REGISTRY.idFromName(registryId(owner));
      const stub = env.REGISTRY.get(id);
      const res = await stub.fetch("https://registry.internal/entries");
      return res;
    }

    const match = url.pathname.match(SESSION_RE);
    if (!match) {
      return jsonError(404, "Not found");
    }

    const [, site, profile] = match;
    const owner = ownerFromRequest(url);
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
        await touchRegistry(env, owner, site, profile, "upsert");
      } else if (request.method === "DELETE") {
        await touchRegistry(env, owner, site, profile, "remove");
      }
    }

    return response;
  },
};
