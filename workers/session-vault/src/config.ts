/** Runtime config from Worker `Env` (wrangler [vars] + secrets). No TS fallbacks. */

export function trimOpt(value: string | undefined): string | undefined {
  const v = value?.trim();
  return v && v.length > 0 ? v : undefined;
}

/** Owner namespace: header → query → DEFAULT_OWNER (all required if missing). */
export function resolveOwner(
  env: Env,
  opts?: { headerOwner?: string | null; queryOwner?: string | null },
): string {
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
    "owner required: set DEFAULT_OWNER on Worker, or ?owner=, or owner tool arg, or owner HTTP header",
  );
}

export function ownerHeaderNames(env: Env): string[] {
  const primary = trimOpt(env.OWNER_HEADER) ?? "X-Cf-Bots-Owner";
  const names = [primary];
  if (primary !== "X-Session-Vault-Owner") {
    names.push("X-Session-Vault-Owner");
  }
  return names;
}

export function readOwnerHeader(request: Request, env: Env): string | undefined {
  for (const name of ownerHeaderNames(env)) {
    const v = trimOpt(request.headers.get(name) ?? undefined);
    if (v) {
      return v;
    }
  }
  return undefined;
}

export function defaultSessionSource(env: Env): string {
  const s = trimOpt(env.DEFAULT_SESSION_SOURCE);
  if (!s) {
    throw new Error("DEFAULT_SESSION_SOURCE is not configured on Worker");
  }
  return s;
}

export function mcpHttpPath(env: Env): string {
  const p = trimOpt(env.MCP_HTTP_PATH);
  if (!p) {
    throw new Error("MCP_HTTP_PATH is not configured on Worker");
  }
  if (!p.startsWith("/")) {
    throw new Error("MCP_HTTP_PATH must start with /");
  }
  return p;
}

export function mcpServerInfo(env: Env): {
  name: string;
  version: string;
  description: string;
} {
  const name = trimOpt(env.MCP_SERVER_NAME);
  const version = trimOpt(env.MCP_SERVER_VERSION);
  const description = trimOpt(env.MCP_SERVER_DESCRIPTION);
  if (!name || !version || !description) {
    throw new Error(
      "MCP_SERVER_NAME, MCP_SERVER_VERSION, MCP_SERVER_DESCRIPTION must be set on Worker",
    );
  }
  return { name, version, description };
}

export function mcpProtocolVersion(env: Env): string {
  const v = trimOpt(env.MCP_PROTOCOL_VERSION);
  if (!v) {
    throw new Error("MCP_PROTOCOL_VERSION is not configured on Worker");
  }
  return v;
}

/** Comma-separated allowlist; empty = only Origin-less + IDE/local dev protocols. */
export function parseAllowedOrigins(env: Env): string[] {
  const raw = trimOpt(env.MCP_ALLOWED_ORIGINS);
  if (!raw) {
    return [];
  }
  return raw
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

export function validateMcpOrigin(request: Request, env: Env): boolean {
  const origin = request.headers.get("Origin");
  if (!origin) {
    return true;
  }
  const allowlist = parseAllowedOrigins(env);
  if (allowlist.length > 0) {
    return allowlist.includes(origin);
  }
  try {
    const u = new URL(origin);
    if (u.protocol === "https:") {
      return true;
    }
    if (u.protocol === "cursor:" || u.protocol === "vscode-file:") {
      return true;
    }
    if (u.hostname === "localhost" || u.hostname === "127.0.0.1") {
      return true;
    }
    return false;
  } catch {
    return false;
  }
}
