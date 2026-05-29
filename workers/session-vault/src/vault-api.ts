const SESSION_RE = /^\/v1\/session\/([^/]+)\/([^/]+)\/?$/;

export function ownerFromRequest(url: URL): string {
  const owner = url.searchParams.get("owner")?.trim();
  return owner && owner.length > 0 ? owner : "default";
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

export async function handleVaultRest(
  request: Request,
  env: Env,
  url: URL,
): Promise<Response> {
  if (request.method === "GET" && url.pathname === "/v1/sessions") {
    const owner = ownerFromRequest(url);
    const id = env.REGISTRY.idFromName(registryId(owner));
    const stub = env.REGISTRY.get(id);
    return stub.fetch("https://registry.internal/entries");
  }

  const match = url.pathname.match(SESSION_RE);
  if (!match) {
    return Response.json({ error: "Not found" }, { status: 404 });
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
}

const KINDS = ["oauth", "cookies", "storage_state"] as const;
type SessionKind = (typeof KINDS)[number];

function resolveOwner(args: Record<string, unknown>, defaultOwner: string): string {
  const owner = String(args.owner ?? "").trim();
  return owner || defaultOwner;
}

/** MCP tool handlers — same semantics as products/session_vault_mcp.py */
export async function vaultToolCall(
  env: Env,
  _baseUrl: string,
  name: string,
  args: Record<string, unknown>,
  defaultOwner = "default",
): Promise<string> {
  const owner = resolveOwner(args, defaultOwner);

  if (name === "session_list") {
    const res = await env.REGISTRY.get(
      env.REGISTRY.idFromName(registryId(owner)),
    ).fetch("https://registry.internal/entries");
    return res.text();
  }

  const site = String(args.site ?? "");
  const profile = String(args.profile ?? "");
  if (!site || !profile) {
    throw new Error("site and profile are required");
  }

  const id = env.SESSION_VAULT.idFromName(vaultId(owner, site, profile));
  const stub = env.SESSION_VAULT.get(id);

  if (name === "session_put") {
    const kind = String(args.kind ?? "");
    if (!KINDS.includes(kind as SessionKind)) {
      throw new Error(`invalid kind: ${kind}`);
    }
    const body: Record<string, unknown> = { [kind]: args.data };
    const expiresAt = args.expires_at;
    if (typeof expiresAt === "string" && expiresAt) {
      body.meta = { expires_at: expiresAt };
    }
    const res = await stub.fetch("https://vault.internal/", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    if (res.ok) {
      await touchRegistry(env, owner, site, profile, "upsert");
    }
    return res.text();
  }

  if (name === "session_get") {
    const kind = args.kind;
    const q =
      typeof kind === "string" && kind
        ? `?kind=${encodeURIComponent(kind)}`
        : "";
    const res = await stub.fetch(`https://vault.internal/${q}`, {
      method: "GET",
    });
    return res.text();
  }

  if (name === "session_delete") {
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
