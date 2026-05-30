import { vaultToolCall } from "./vault-api";
import { SESSION_KINDS } from "./kinds";

const TOOL_DEFS = [
  {
    name: "sess_save",
    description:
      "Save browser-use / Playwright session for reuse across Cloud Agents (storage_state + optional oauth/cookies/config)",
    required: ["site", "profile"],
    properties: {
      site: { type: "string", description: "Site key (e.g. github.com)" },
      profile: { type: "string", description: "Profile name (e.g. default)" },
      storage_state: {
        description: "Playwright storageState JSON (cookies + origins)",
      },
      oauth: { description: "OAuth token bundle JSON" },
      cookies: { description: "Raw cookie list JSON" },
      config: {
        description: "browser-use or agent config JSON (API URLs, selectors, etc.)",
      },
      label: { type: "string", description: "Human label in sess_list" },
      source: {
        type: "string",
        description: "Source tag (default browser-use)",
      },
      tags: {
        type: "array",
        items: { type: "string" },
        description: "Tags for filtering sess_list",
      },
      notes: { type: "string" },
      expires_at: { type: "string", description: "ISO8601 expiry" },
      owner: { type: "string", description: "Owner namespace (cloud-agent team)" },
    },
  },
  {
    name: "sess_load",
    description:
      "Load saved browser session for browser-use (storage_state; optional oauth/cookies/config)",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      include_oauth: { type: "boolean" },
      include_cookies: { type: "boolean" },
      include_config: { type: "boolean" },
      owner: { type: "string" },
    },
  },
  {
    name: "sess_meta",
    description: "Read label/tags/source/expiry metadata without decrypting payloads",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      owner: { type: "string" },
    },
  },
  {
    name: "sess_put",
    description: "Store a single kind: oauth, cookies, storage_state, or config",
    required: ["site", "profile", "kind", "data"],
    properties: {
      site: { type: "string", description: "Site key (e.g. claude.ai)" },
      profile: { type: "string", description: "Profile name" },
      kind: { type: "string", enum: [...SESSION_KINDS] },
      data: { description: "JSON-serializable session payload" },
      owner: { type: "string" },
      label: { type: "string" },
      source: { type: "string" },
      tags: { type: "array", items: { type: "string" } },
      notes: { type: "string" },
      expires_at: { type: "string" },
    },
  },
  {
    name: "sess_get",
    description: "Read stored session fields (optional single kind)",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      kind: { type: "string", enum: [...SESSION_KINDS] },
      owner: { type: "string" },
    },
  },
  {
    name: "sess_delete",
    description: "Delete all encrypted session data for site/profile",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      owner: { type: "string" },
    },
  },
  {
    name: "sess_list",
    description: "List site/profile entries with label/source/tags",
    required: [] as string[],
    properties: {
      owner: { type: "string" },
      source: { type: "string", description: "Filter by meta.source" },
      tag: { type: "string", description: "Filter entries containing tag" },
    },
  },
] as const;

const SERVER_INFO = {
  name: "mcp-cf-bots",
  version: "0.4.0",
  description:
    "Cloudflare MCP for cross-agent bots (sessions; memory planned)",
};

type JsonRpcReq = {
  jsonrpc?: string;
  id?: string | number | null;
  method?: string;
  params?: Record<string, unknown>;
};

function ok(id: string | number | null | undefined, result: unknown) {
  return { jsonrpc: "2.0" as const, id: id ?? null, result };
}

function err(id: string | number | null | undefined, code: number, message: string) {
  return {
    jsonrpc: "2.0" as const,
    id: id ?? null,
    error: { code, message },
  };
}

export async function handleMcpJsonRpc(
  request: JsonRpcReq,
  ctx: {
    env: Env;
    baseUrl: string;
    defaultOwner: string;
    sessionId: string | null;
    isInitialize: boolean;
  },
): Promise<{ body: unknown; status: number; isNotification: boolean }> {
  const method = request.method;
  const params = (request.params ?? {}) as Record<string, unknown>;
  const requestId = request.id;

  if (method === "notifications/initialized" || method === "initialized") {
    return { body: null, status: 202, isNotification: true };
  }

  if (method === "initialize") {
    return {
      body: ok(requestId, {
        protocolVersion: "2024-11-05",
        capabilities: { tools: {} },
        serverInfo: SERVER_INFO,
      }),
      status: 200,
      isNotification: false,
    };
  }

  if (!ctx.isInitialize && !ctx.sessionId) {
    return {
      body: err(requestId, -32000, "Missing or invalid MCP-Session-Id"),
      status: 400,
      isNotification: false,
    };
  }

  if (method === "tools/list") {
    return {
      body: ok(requestId, {
        tools: TOOL_DEFS.map((t) => ({
          name: t.name,
          description: t.description,
          inputSchema: {
            type: "object",
            properties: t.properties,
            required: [...t.required],
          },
        })),
      }),
      status: 200,
      isNotification: false,
    };
  }

  if (method === "tools/call") {
    const name = String(params.name ?? "");
    const args = (params.arguments ?? {}) as Record<string, unknown>;
    const known = TOOL_DEFS.some((t) => t.name === name);
    if (!known) {
      return {
        body: err(requestId, -32602, `Unknown tool: ${name}`),
        status: 200,
        isNotification: false,
      };
    }
    try {
      const text = await vaultToolCall(
        ctx.env,
        ctx.baseUrl,
        name,
        args,
        ctx.defaultOwner,
      );
      return {
        body: ok(requestId, {
          content: [{ type: "text", text }],
        }),
        status: 200,
        isNotification: false,
      };
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      return {
        body: ok(requestId, {
          content: [{ type: "text", text: `Error: ${message}` }],
        }),
        status: 200,
        isNotification: false,
      };
    }
  }

  if (requestId === undefined) {
    return { body: null, status: 202, isNotification: true };
  }

  return {
    body: err(requestId, -32601, `Method not found: ${method}`),
    status: 200,
    isNotification: false,
  };
}
