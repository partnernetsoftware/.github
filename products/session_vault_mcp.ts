#!/usr/bin/env bun
/**
 * Session Vault MCP — local Bun/TS stdio tool (NOT deployed to CF).
 * Calls the Cloudflare Worker REST API (Workers runtime is separate under workers/session-vault/).
 *
 *   claude mcp add session-vault bun /workspace/products/session_vault_mcp.ts server
 *
 * Env: SESSION_VAULT_URL, SESSION_VAULT_TOKEN, optional SESSION_VAULT_OWNER (default: default)
 */

const KINDS = ["oauth", "cookies", "storage_state"] as const;
type SessionKind = (typeof KINDS)[number];

type JsonRpcRequest = {
  jsonrpc?: string;
  id?: string | number | null;
  method?: string;
  params?: Record<string, unknown>;
};

type JsonRpcResponse = {
  jsonrpc: "2.0";
  id: string | number | null;
  result?: unknown;
  error?: { code: number; message: string };
};

type ToolDef = {
  name: string;
  description: string;
  parameters: Record<string, unknown>;
  required: string[];
  handler: (args: Record<string, unknown>) => Promise<string>;
};

function baseUrl(): string {
  const url = (process.env.SESSION_VAULT_URL ?? "").trim().replace(/\/$/, "");
  if (!url) throw new Error("SESSION_VAULT_URL is not set");
  return url;
}

function vaultToken(): string {
  const token = (process.env.SESSION_VAULT_TOKEN ?? "").trim();
  if (!token) throw new Error("SESSION_VAULT_TOKEN is not set");
  return token;
}

function defaultOwner(): string {
  return (process.env.SESSION_VAULT_OWNER ?? "default").trim() || "default";
}

function resolveOwner(args: Record<string, unknown>): string {
  const o = typeof args.owner === "string" ? args.owner.trim() : "";
  return o || defaultOwner();
}

function sessionPath(site: string, profile: string): string {
  return `/v1/session/${encodeURIComponent(site)}/${encodeURIComponent(profile)}`;
}

async function vaultFetch(
  method: string,
  path: string,
  opts?: { body?: Record<string, unknown>; query?: Record<string, string> },
): Promise<unknown> {
  let url = `${baseUrl()}${path}`;
  if (opts?.query && Object.keys(opts.query).length > 0) {
    url += `?${new URLSearchParams(opts.query)}`;
  }

  const res = await fetch(url, {
    method,
    headers: {
      Authorization: `Bearer ${vaultToken()}`,
      Accept: "application/json",
      ...(opts?.body ? { "Content-Type": "application/json" } : {}),
    },
    body: opts?.body ? JSON.stringify(opts.body) : undefined,
  });

  const text = await res.text();
  let parsed: unknown = {};
  if (text) {
    try {
      parsed = JSON.parse(text);
    } catch {
      parsed = { raw: text };
    }
  }

  if (!res.ok) {
    const err =
      typeof parsed === "object" &&
      parsed !== null &&
      "error" in parsed &&
      typeof (parsed as { error: unknown }).error === "string"
        ? (parsed as { error: string }).error
        : res.statusText;
    throw new Error(`HTTP ${res.status}: ${err}`);
  }
  return parsed;
}

const tools: ToolDef[] = [
  {
    name: "session_put",
    description: "Store oauth, cookies, or Playwright storage_state for site/profile",
    parameters: {
      site: { type: "string", description: "Site key (e.g. claude.ai)" },
      profile: { type: "string", description: "Profile name" },
      kind: { type: "string", enum: [...KINDS] },
      data: { description: "JSON-serializable session payload" },
      owner: { type: "string", description: "Owner namespace" },
      expires_at: { type: "string", description: "Optional ISO8601 expiry" },
    },
    required: ["site", "profile", "kind", "data"],
    async handler(args) {
      const kind = String(args.kind);
      if (!KINDS.includes(kind as SessionKind)) {
        throw new Error(`invalid kind: ${kind}`);
      }
      const body: Record<string, unknown> = { [kind]: args.data };
      if (typeof args.expires_at === "string" && args.expires_at) {
        body.meta = { expires_at: args.expires_at };
      }
      const result = await vaultFetch("PUT", sessionPath(String(args.site), String(args.profile)), {
        body,
        query: { owner: resolveOwner(args) },
      });
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: "session_get",
    description: "Read stored session fields (optional single kind)",
    parameters: {
      site: { type: "string" },
      profile: { type: "string" },
      kind: { type: "string", enum: [...KINDS] },
      owner: { type: "string" },
    },
    required: ["site", "profile"],
    async handler(args) {
      const query: Record<string, string> = { owner: resolveOwner(args) };
      if (typeof args.kind === "string" && args.kind) query.kind = args.kind;
      const result = await vaultFetch(
        "GET",
        sessionPath(String(args.site), String(args.profile)),
        { query },
      );
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: "session_delete",
    description: "Delete all encrypted session data for site/profile",
    parameters: {
      site: { type: "string" },
      profile: { type: "string" },
      owner: { type: "string" },
    },
    required: ["site", "profile"],
    async handler(args) {
      const result = await vaultFetch(
        "DELETE",
        sessionPath(String(args.site), String(args.profile)),
        { query: { owner: resolveOwner(args) } },
      );
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: "session_list",
    description: "List known site/profile entries (Registry DO index)",
    parameters: {
      owner: { type: "string", description: "Owner namespace" },
    },
    required: [],
    async handler(args) {
      const result = await vaultFetch("GET", "/v1/sessions", {
        query: { owner: resolveOwner(args) },
      });
      return JSON.stringify(result, null, 2);
    },
  },
];

const toolMap = new Map(tools.map((t) => [t.name, t]));

function ok(id: string | number | null, result: unknown): JsonRpcResponse {
  return { jsonrpc: "2.0", id, result };
}

function err(id: string | number | null, code: number, message: string): JsonRpcResponse {
  return { jsonrpc: "2.0", id, error: { code, message } };
}

async function handleRequest(req: JsonRpcRequest): Promise<JsonRpcResponse | null> {
  const { method, params = {}, id = null } = req;

  if (method === "initialize") {
    return ok(id, {
      protocolVersion: "2024-11-05",
      capabilities: { tools: {} },
      serverInfo: {
        name: "session-vault-mcp",
        version: "0.1.0",
        description: "Encrypted OAuth/cookie/storageState vault (Cloudflare DO)",
      },
    });
  }
  if (method === "initialized") return null;

  if (method === "tools/list") {
    return ok(id, {
      tools: tools.map((t) => ({
        name: t.name,
        description: t.description,
        inputSchema: {
          type: "object",
          properties: t.parameters,
          required: t.required,
        },
      })),
    });
  }

  if (method === "tools/call") {
    const name = String(params.name ?? "");
    const args = (params.arguments ?? {}) as Record<string, unknown>;
    const tool = toolMap.get(name);
    if (!tool) return err(id, -32602, `Unknown tool: ${name}`);
    try {
      const text = await tool.handler(args);
      return ok(id, { content: [{ type: "text", text }] });
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      return ok(id, { content: [{ type: "text", text: `Error: ${message}` }] });
    }
  }

  return err(id, -32601, `Method not found: ${method}`);
}

async function runStdio(): Promise<void> {
  const reader = Bun.stdin.stream().getReader();
  const decoder = new TextDecoder();
  let buffer = "";

  console.error("Session Vault MCP started (stdio, bun)");

  while (true) {
    const { value, done } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });
    const lines = buffer.split("\n");
    buffer = lines.pop() ?? "";

    for (const line of lines) {
      const trimmed = line.trim();
      if (!trimmed) continue;
      let req: JsonRpcRequest;
      try {
        req = JSON.parse(trimmed) as JsonRpcRequest;
      } catch {
        continue;
      }
      const res = await handleRequest(req);
      if (res) console.log(JSON.stringify(res));
    }
  }
}

if (import.meta.main) {
  const cmd = process.argv[2];
  if (cmd === "server") {
    await runStdio();
  } else {
    console.error("Usage: bun session_vault_mcp.ts server");
    process.exit(1);
  }
}
