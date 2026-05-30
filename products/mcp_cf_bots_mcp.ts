#!/usr/bin/env bun
/**
 * mcp-cf-bots — local Bun/TS stdio MCP (calls Cloudflare Worker REST API).
 *
 *   claude mcp add mcp-cf-bots bun /workspace/products/mcp_cf_bots_mcp.ts server
 *
 * Env: MCP_CF_BOTS_URL, MCP_CF_BOTS_TOKEN, optional MCP_CF_BOTS_OWNER
 * Legacy: SESSION_VAULT_URL, SESSION_VAULT_TOKEN, SESSION_VAULT_OWNER
 */

const KINDS = ["oauth", "cookies", "storage_state", "config"] as const;
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

function env(primary: string, legacy: string): string {
  const val = (process.env[primary] ?? "").trim();
  if (val) return val;
  return (process.env[legacy] ?? "").trim();
}

function baseUrl(): string {
  const url = env("MCP_CF_BOTS_URL", "SESSION_VAULT_URL").replace(/\/$/, "");
  if (!url) throw new Error("MCP_CF_BOTS_URL is not set (legacy: SESSION_VAULT_URL)");
  return url;
}

function vaultToken(): string {
  const token = env("MCP_CF_BOTS_TOKEN", "SESSION_VAULT_TOKEN");
  if (!token) throw new Error("MCP_CF_BOTS_TOKEN is not set (legacy: SESSION_VAULT_TOKEN)");
  return token;
}

function defaultOwner(): string {
  const owner = env("MCP_CF_BOTS_OWNER", "SESSION_VAULT_OWNER");
  return owner || "default";
}

function resolveOwner(args: Record<string, unknown>): string {
  const o = typeof args.owner === "string" ? args.owner.trim() : "";
  return o || defaultOwner();
}

function sessionPath(site: string, profile: string): string {
  return `/v1/session/${encodeURIComponent(site)}/${encodeURIComponent(profile)}`;
}

function metaFromArgs(args: Record<string, unknown>): Record<string, unknown> {
  const meta: Record<string, unknown> = {};
  for (const key of ["expires_at", "label", "source", "notes"] as const) {
    const val = args[key];
    if (typeof val === "string" && val) meta[key] = val;
  }
  if (Array.isArray(args.tags)) {
    meta.tags = args.tags.map(String);
  }
  return meta;
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
    name: "sess_save",
    description: "Save browser-use / Playwright session for cross-agent reuse",
    parameters: {
      site: { type: "string" },
      profile: { type: "string" },
      storage_state: { description: "Playwright storageState" },
      oauth: { description: "OAuth JSON" },
      cookies: { description: "Cookie list JSON" },
      config: { description: "browser-use config JSON" },
      label: { type: "string" },
      source: { type: "string" },
      tags: { type: "array", items: { type: "string" } },
      notes: { type: "string" },
      expires_at: { type: "string" },
      owner: { type: "string" },
    },
    required: ["site", "profile"],
    async handler(args) {
      const body: Record<string, unknown> = {};
      for (const key of ["storage_state", "oauth", "cookies", "config"] as const) {
        if (args[key] !== undefined) body[key] = args[key];
      }
      const meta = metaFromArgs(args);
      if (!meta.source) meta.source = "browser-use";
      if (Object.keys(meta).length > 0) body.meta = meta;
      if (Object.keys(body).length === 0) {
        throw new Error("provide at least one of storage_state, oauth, cookies, config");
      }
      const result = await vaultFetch("PUT", sessionPath(String(args.site), String(args.profile)), {
        body,
        query: { owner: resolveOwner(args) },
      });
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: "sess_load",
    description: "Load browser-use session (storage_state + optional fields)",
    parameters: {
      site: { type: "string" },
      profile: { type: "string" },
      include_oauth: { type: "boolean" },
      include_cookies: { type: "boolean" },
      include_config: { type: "boolean" },
      owner: { type: "string" },
    },
    required: ["site", "profile"],
    async handler(args) {
      const result = (await vaultFetch(
        "GET",
        sessionPath(String(args.site), String(args.profile)),
        { query: { owner: resolveOwner(args) } },
      )) as Record<string, unknown>;
      if (!args.include_oauth && !args.include_cookies && !args.include_config) {
        const slim: Record<string, unknown> = { meta: result.meta };
        if (result.storage_state !== undefined) slim.storage_state = result.storage_state;
        return JSON.stringify(slim, null, 2);
      }
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: "sess_meta",
    description: "Read session metadata only",
    parameters: {
      site: { type: "string" },
      profile: { type: "string" },
      owner: { type: "string" },
    },
    required: ["site", "profile"],
    async handler(args) {
      const q = new URLSearchParams({
        owner: resolveOwner(args),
        meta_only: "1",
      });
      const res = await fetch(
        `${baseUrl()}${sessionPath(String(args.site), String(args.profile))}?${q}`,
        {
          headers: { Authorization: `Bearer ${vaultToken()}`, Accept: "application/json" },
        },
      );
      return JSON.stringify(await res.json(), null, 2);
    },
  },
  {
    name: "sess_put",
    description: "Store oauth, cookies, storage_state, or config for site/profile",
    parameters: {
      site: { type: "string" },
      profile: { type: "string" },
      kind: { type: "string", enum: [...KINDS] },
      data: { description: "JSON payload" },
      owner: { type: "string" },
      label: { type: "string" },
      source: { type: "string" },
      tags: { type: "array", items: { type: "string" } },
      notes: { type: "string" },
      expires_at: { type: "string" },
    },
    required: ["site", "profile", "kind", "data"],
    async handler(args) {
      const kind = String(args.kind);
      if (!KINDS.includes(kind as SessionKind)) throw new Error(`invalid kind: ${kind}`);
      const body: Record<string, unknown> = { [kind]: args.data };
      const meta = metaFromArgs(args);
      if (Object.keys(meta).length > 0) body.meta = meta;
      const result = await vaultFetch("PUT", sessionPath(String(args.site), String(args.profile)), {
        body,
        query: { owner: resolveOwner(args) },
      });
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: "sess_get",
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
    name: "sess_delete",
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
    name: "sess_list",
    description: "List known site/profile entries",
    parameters: {
      owner: { type: "string" },
      source: { type: "string" },
      tag: { type: "string" },
    },
    required: [],
    async handler(args) {
      const query: Record<string, string> = { owner: resolveOwner(args) };
      if (typeof args.source === "string" && args.source) query.source = args.source;
      if (typeof args.tag === "string" && args.tag) query.tag = args.tag;
      const result = await vaultFetch("GET", "/v1/sessions", { query });
      return JSON.stringify(result, null, 2);
    },
  },
];

const toolMap = new Map(tools.map((t) => [t.name, t]));

function ok(id: string | number | null, result: unknown): JsonRpcResponse {
  return { jsonrpc: "2.0", id, result };
}

function rpcErr(id: string | number | null, code: number, message: string): JsonRpcResponse {
  return { jsonrpc: "2.0", id, error: { code, message } };
}

async function handleRequest(req: JsonRpcRequest): Promise<JsonRpcResponse | null> {
  const { method, params = {}, id = null } = req;

  if (method === "initialize") {
    return ok(id, {
      protocolVersion: "2024-11-05",
      capabilities: { tools: {} },
      serverInfo: {
        name: "mcp-cf-bots",
        version: "0.4.0",
        description: "Cloudflare MCP for cross-agent bots (sessions; memory planned)",
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
    if (!tool) return rpcErr(id, -32602, `Unknown tool: ${name}`);
    try {
      const text = await tool.handler(args);
      return ok(id, { content: [{ type: "text", text }] });
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      return ok(id, { content: [{ type: "text", text: `Error: ${message}` }] });
    }
  }

  return rpcErr(id, -32601, `Method not found: ${method}`);
}

async function runStdio(): Promise<void> {
  const reader = Bun.stdin.stream().getReader();
  const decoder = new TextDecoder();
  let buffer = "";

  console.error("mcp-cf-bots started (stdio, bun)");

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
    console.error("Usage: bun mcp_cf_bots_mcp.ts server");
    process.exit(1);
  }
}
