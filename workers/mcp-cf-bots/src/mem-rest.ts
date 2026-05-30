import { effectiveOwner, isAdmin, type AuthContext } from "./auth";
import { readOwnerHeader } from "./config";
import { apiError } from "./http-util";
import { memToolCall } from "./mem-tools";
import { validateKey } from "./validate";

const MEM_KEY_RE = /^\/v1\/mem\/([^/]+)\/?$/;

export function ownerFromMemRequest(
  auth: AuthContext,
  env: Env,
  url: URL,
  request: Request,
): string {
  return effectiveOwner(auth, env, {
    headerOwner: readOwnerHeader(request, env),
    queryOwner: url.searchParams.get("owner"),
  });
}

export async function handleMemRest(
  request: Request,
  env: Env,
  url: URL,
  auth: AuthContext,
): Promise<Response | null> {
  if (!url.pathname.startsWith("/v1/mem")) {
    return null;
  }
  if (!env.MEMORY_STORE) {
    return apiError(503, "Memory store is not configured");
  }

  const owner = ownerFromMemRequest(auth, env, url, request);

  if (url.pathname === "/v1/mem/import" && request.method === "POST") {
    let body: { entries?: unknown };
    try {
      body = (await request.json()) as { entries?: unknown };
    } catch {
      return apiError(400, "Invalid JSON");
    }
    const text = await memToolCall(
      env,
      "mem_import",
      { entries: body.entries, owner },
      auth,
      owner,
    );
    return new Response(text, {
      headers: { "Content-Type": "application/json" },
    });
  }

  if (url.pathname === "/v1/mem/stats" && request.method === "GET") {
    if (!isAdmin(auth)) {
      return apiError(403, "Forbidden");
    }
    const text = await memToolCall(
      env,
      "mem_stats",
      { owner: url.searchParams.get("owner") ?? owner },
      auth,
      owner,
    );
    return new Response(text, {
      headers: { "Content-Type": "application/json" },
    });
  }

  if (url.pathname === "/v1/mem/reindex" && request.method === "POST") {
    if (!isAdmin(auth)) {
      return apiError(403, "Forbidden");
    }
    let body: { owner?: string } = {};
    try {
      const raw = await request.text();
      if (raw.trim()) {
        body = JSON.parse(raw) as { owner?: string };
      }
    } catch {
      return apiError(400, "Invalid JSON");
    }
    const text = await memToolCall(
      env,
      "mem_reindex",
      { owner: body.owner ?? owner },
      auth,
      owner,
    );
    return new Response(text, {
      headers: { "Content-Type": "application/json" },
    });
  }

  if (url.pathname === "/v1/mem/search" && request.method === "POST") {
    let body: { query?: string; top_k?: number };
    try {
      body = (await request.json()) as { query?: string; top_k?: number };
    } catch {
      return apiError(400, "Invalid JSON");
    }
    const text = await memToolCall(
      env,
      "mem_search",
      { ...body, owner },
      auth,
      owner,
    );
    return new Response(text, {
      headers: { "Content-Type": "application/json" },
    });
  }

  if (url.pathname === "/v1/mem" && request.method === "GET") {
    const text = await memToolCall(
      env,
      "mem_list",
      { tag: url.searchParams.get("tag"), owner },
      auth,
      owner,
    );
    return new Response(text, {
      headers: { "Content-Type": "application/json" },
    });
  }

  const match = url.pathname.match(MEM_KEY_RE);
  if (!match) {
    return apiError(404, "Not found");
  }

  const key = validateKey("key", decodeURIComponent(match[1]!));

  if (request.method === "GET") {
    try {
      const text = await memToolCall(env, "mem_get", { key, owner }, auth, owner);
      return new Response(text, {
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      return apiError(404, message);
    }
  }

  if (request.method === "PUT") {
    let body: { content?: string; tags?: unknown; expires_at?: string };
    try {
      body = (await request.json()) as {
        content?: string;
        tags?: unknown;
        expires_at?: string;
      };
    } catch {
      return apiError(400, "Invalid JSON");
    }
    const text = await memToolCall(
      env,
      "mem_put",
      {
        key,
        content: body.content,
        tags: body.tags,
        expires_at: body.expires_at,
        owner,
      },
      auth,
      owner,
    );
    return new Response(text, {
      headers: { "Content-Type": "application/json" },
    });
  }

  if (request.method === "DELETE") {
    try {
      const text = await memToolCall(
        env,
        "mem_delete",
        { key, owner },
        auth,
        owner,
      );
      return new Response(text, {
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      return apiError(404, message);
    }
  }

  return apiError(405, "Method not allowed");
}
