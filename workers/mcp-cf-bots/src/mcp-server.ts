import type { AuthContext } from "./auth";
import { mcpProtocolVersion, mcpServerInfo } from "./config";
import { mcpServerInstructions } from "./mcp-instructions";
import { listMemResources, readMemResource } from "./mcp-resources";
import { checkOwnerRateLimit } from "./rate-limit";
import { memToolCall } from "./mem-tools";
import { sessToolCall } from "./sess-tools";
import { resolveToolName } from "./tool-aliases";
import { toolsForAuth } from "./tool-defs";

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
      const serverInfo = mcpServerInfo(ctx.env);
      return {
        body: ok(requestId, {
          protocolVersion: mcpProtocolVersion(ctx.env),
          capabilities: { tools: {}, resources: {} },
          serverInfo: {
            ...serverInfo,
            auth:
              ctx.auth.role === "admin"
                ? { role: "admin" as const }
                : {
                    role: "user" as const,
                    owner: ctx.auth.owner,
                  },
          },
          instructions: mcpServerInstructions(ctx.env),
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

  if (method === "resources/list") {
    await checkOwnerRateLimit(ctx.env, ctx.requestOwner, "mem_list");
    const resources = await listMemResources(
      ctx.env,
      ctx.auth,
      ctx.requestOwner,
    );
    return {
      body: ok(requestId, { resources }),
      status: 200,
      isNotification: false,
    };
  }

  if (method === "resources/read") {
    const uri = params.uri;
    if (typeof uri !== "string" || !uri) {
      return {
        body: err(requestId, -32602, "Missing required parameter: uri"),
        status: 200,
        isNotification: false,
      };
    }
    await checkOwnerRateLimit(ctx.env, ctx.requestOwner, "mem_get");
    const content = await readMemResource(
      ctx.env,
      ctx.auth,
      ctx.requestOwner,
      uri,
    );
    if (!content) {
      return {
        body: err(requestId, -32602, `Resource not found: ${uri}`),
        status: 200,
        isNotification: false,
      };
    }
    return {
      body: ok(requestId, {
        contents: [
          {
            uri: content.uri,
            mimeType: content.mimeType,
            text: content.text,
          },
        ],
      }),
      status: 200,
      isNotification: false,
    };
  }

  if (method === "tools/call") {
    const name = resolveToolName(String(params.name ?? ""));
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
      const text = name.startsWith("mem_")
        ? await memToolCall(ctx.env, name, args, ctx.auth, ctx.requestOwner)
        : await sessToolCall(ctx.env, name, args, ctx.auth, ctx.requestOwner);
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
