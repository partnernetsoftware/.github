import { vaultToolCall } from "./vault-api";

const KINDS = ["oauth", "cookies", "storage_state"] as const;

const TOOL_DEFS = [
  {
    name: "session_put",
    description:
      "Store oauth, cookies, or Playwright storage_state for site/profile",
    required: ["site", "profile", "kind", "data"],
    properties: {
      site: { type: "string", description: "Site key (e.g. claude.ai)" },
      profile: { type: "string", description: "Profile name" },
      kind: { type: "string", enum: [...KINDS] },
      data: { description: "JSON-serializable session payload" },
      owner: { type: "string", description: "Owner namespace" },
      expires_at: { type: "string", description: "Optional ISO8601 expiry" },
    },
  },
  {
    name: "session_get",
    description: "Read stored session fields (optional single kind)",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      kind: { type: "string", enum: [...KINDS] },
      owner: { type: "string" },
    },
  },
  {
    name: "session_delete",
    description: "Delete all encrypted session data for site/profile",
    required: ["site", "profile"],
    properties: {
      site: { type: "string" },
      profile: { type: "string" },
      owner: { type: "string" },
    },
  },
  {
    name: "session_list",
    description: "List known site/profile entries (Registry DO index)",
    required: [] as string[],
    properties: {
      owner: { type: "string", description: "Owner namespace" },
    },
  },
] as const;

const SERVER_INFO = {
  name: "session-vault-mcp",
  version: "0.2.0",
  description: "Encrypted OAuth/cookie/storageState vault (Cloudflare DO)",
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
