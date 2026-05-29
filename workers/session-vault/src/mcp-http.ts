import { handleMcpJsonRpc } from "./mcp-server";

function acceptsMcpPost(request: Request): boolean {
  const accept = request.headers.get("Accept") ?? "";
  return (
    accept.includes("application/json") &&
    accept.includes("text/event-stream")
  );
}

function acceptsMcpGet(request: Request): boolean {
  const accept = request.headers.get("Accept") ?? "";
  return accept.includes("text/event-stream");
}

/** Spec: reject invalid Origin when present (DNS rebinding). */
function validateOrigin(request: Request): boolean {
  const origin = request.headers.get("Origin");
  if (!origin) {
    return true;
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

async function hmacSessionToken(secret: string, sessionUuid: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(sessionUuid),
  );
  const bytes = new Uint8Array(sig);
  let binary = "";
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]!);
  }
  const sigB64 = btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
  return `${sessionUuid}.${sigB64}`;
}

export async function mintSessionId(env: Env): Promise<string> {
  const uuid = crypto.randomUUID();
  return hmacSessionToken(env.VAULT_TOKEN, uuid);
}

export async function validateSessionId(
  env: Env,
  sessionId: string | null,
): Promise<boolean> {
  if (!sessionId?.trim()) {
    return false;
  }
  const dot = sessionId.lastIndexOf(".");
  if (dot <= 0) {
    return false;
  }
  const uuid = sessionId.slice(0, dot);
  const expected = await hmacSessionToken(env.VAULT_TOKEN, uuid);
  return expected === sessionId;
}

function isJsonRpcBody(body: unknown): body is { method?: string; jsonrpc?: string } {
  return (
    typeof body === "object" &&
    body !== null &&
    ("jsonrpc" in body || "method" in body)
  );
}

export function isMcpHttpRequest(request: Request, url: URL): boolean {
  if (url.pathname === "/mcp") {
    return true;
  }
  if (url.pathname !== "/") {
    return false;
  }
  if (request.method === "GET") {
    return acceptsMcpGet(request);
  }
  if (request.method === "POST") {
    return acceptsMcpPost(request);
  }
  if (request.method === "DELETE") {
    return Boolean(request.headers.get("MCP-Session-Id"));
  }
  return false;
}

export async function handleMcpHttp(
  request: Request,
  env: Env,
  url: URL,
): Promise<Response> {
  if (!validateOrigin(request)) {
    return Response.json(
      { jsonrpc: "2.0", error: { code: -32000, message: "Invalid Origin" } },
      { status: 403 },
    );
  }

  const headerOwner = request.headers.get("X-Session-Vault-Owner")?.trim();
  const defaultOwner =
    headerOwner || env.DEFAULT_OWNER?.trim() || "default";

  if (request.method === "GET") {
    if (!acceptsMcpGet(request)) {
      return new Response("Method Not Allowed", { status: 405 });
    }
    return new Response("SSE not implemented; use POST JSON responses", {
      status: 405,
    });
  }

  if (request.method === "DELETE") {
    return new Response(null, { status: 204 });
  }

  if (request.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  if (!acceptsMcpPost(request)) {
    return Response.json(
      { error: "Accept must include application/json and text/event-stream" },
      { status: 406 },
    );
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return Response.json({ error: "Invalid JSON" }, { status: 400 });
  }

  if (!isJsonRpcBody(body)) {
    return Response.json({ error: "Not JSON-RPC" }, { status: 400 });
  }

  const sessionHeader = request.headers.get("MCP-Session-Id");
  const isInitialize = body.method === "initialize";
  const sessionValid = sessionHeader
    ? await validateSessionId(env, sessionHeader)
    : false;

  const baseUrl = url.origin;
  const result = await handleMcpJsonRpc(body, {
    env,
    baseUrl,
    defaultOwner,
    sessionId: sessionValid ? sessionHeader : null,
    isInitialize,
  });

  if (result.isNotification) {
    return new Response(null, { status: result.status });
  }

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    "Cache-Control": "no-cache",
  };

  if (isInitialize && result.status === 200) {
    const newSession = await mintSessionId(env);
    headers["MCP-Session-Id"] = newSession;
  } else if (sessionValid && sessionHeader) {
    headers["MCP-Session-Id"] = sessionHeader;
  }

  return new Response(JSON.stringify(result.body), {
    status: result.status,
    headers,
  });
}
