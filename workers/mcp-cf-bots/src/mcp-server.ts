import { isAdmin, type AuthContext } from "./auth";
import { mcpProtocolVersion, mcpServerInfo } from "./config";
import { vaultToolCall } from "./sess-tools";
import { SESSION_KINDS } from "./kinds";

type ToolDef = {
  name: string;
  description: string;
  required: readonly string[];
  properties: Record<string, unknown>;
};

const ADMIN_TOOL_DEFS: ToolDef[] = [
  {
    name: "auth_token_create",
    description: "Admin: issue a per-user Bearer token scoped to one owner namespace",
    required: ["owner"],
    properties: {
      owner: { type: "string", description: "Tenant / user id (vault namespace)" },
      label: { type: "string", description: "Optional note (e.g. alice-cursor)" },
    },
  },
  {
    name: "auth_token_list",
    description: "Admin: list issued user tokens (metadata only, not secret values)",
    required: [],
    properties: {
      owner: { type: "string", description: "Filter by owner" },
    },
  },
  {
    name: "auth_token_revoke",
    description: "Admin: revoke a user token by id",
    required: ["token_id"],
    properties: {
      token_id: { type: "string" },
    },
  },
];

const SESS_TOOL_DEFS: ToolDef[] = [
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
];

function toolsForAuth(auth: AuthContext): ToolDef[] {
  const sess = SESS_TOOL_DEFS.map((t) => {
    if (auth.role === "user") {
      const { owner: _o, ...properties } = t.properties as Record<string, unknown> & {
        owner?: unknown;
      };
      const required = t.required.filter((r) => r !== "owner");
      return { ...t, properties, required };
    }
    return t;
  });
  if (isAdmin(auth)) {
    return [...sess, ...ADMIN_TOOL_DEFS];
  }
  return sess;
}

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
    auth: AuthContext;
    requestOwner: string;
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
    try {
      return {
        body: ok(requestId, {
          protocolVersion: mcpProtocolVersion(ctx.env),
          capabilities: { tools: {} },
          serverInfo: mcpServerInfo(ctx.env),
        }),
        status: 200,
        isNotification: false,
      };
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      return {
        body: err(requestId, -32000, message),
        status: 500,
        isNotification: false,
      };
    }
  }

  if (!ctx.isInitialize && !ctx.sessionId) {
    return {
      body: err(requestId, -32000, "Missing or invalid MCP-Session-Id"),
      status: 400,
      isNotification: false,
    };
  }

  const toolDefs = toolsForAuth(ctx.auth);

  if (method === "tools/list") {
    return {
      body: ok(requestId, {
        tools: toolDefs.map((t) => ({
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
    const known = toolDefs.some((t) => t.name === name);
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
        name,
        args,
        ctx.auth,
        ctx.requestOwner,
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
