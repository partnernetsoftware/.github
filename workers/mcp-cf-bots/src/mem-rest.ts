import { isAdmin, type AuthContext } from "./auth";
import { apiError, jsonResponse, readJsonBody, readOptionalJsonBody } from "./http-util";
import { memToolCall } from "./mem-tools";
import { ownerFromHttpRequest } from "./owner-scope";
import { validateKey } from "./validate";

const MEM_KEY_RE = /^\/v1\/mem\/([^/]+)\/?$/;

/** @deprecated Use ownerFromHttpRequest */
export const ownerFromMemRequest = ownerFromHttpRequest;

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

  const owner = ownerFromHttpRequest(auth, env, url, request);

  const jsonError = (e: unknown) => {
    const message = e instanceof Error ? e.message : String(e);
    return message === "Invalid JSON"
      ? apiError(400, "Invalid JSON")
      : apiError(400, message);
  };

  if (url.pathname === "/v1/mem/import" && request.method === "POST") {
    try {
      const body = await readJsonBody<{ entries?: unknown }>(request);
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
    } catch (e) {
      return jsonError(e);
    }
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

  if (url.pathname === "/v1/mem/vector-gc" && request.method === "POST") {
    if (!isAdmin(auth)) {
      return apiError(403, "Forbidden");
    }
    try {
      const body = await readOptionalJsonBody<{
        owner?: string;
        dry_run?: boolean;
      }>(request);
      const text = await memToolCall(
        env,
        "mem_vector_gc",
        { owner: body.owner ?? owner, dry_run: body.dry_run },
        auth,
        owner,
      );
      return new Response(text, {
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      return jsonError(e);
    }
  }

  if (url.pathname === "/v1/mem/migrate-legacy" && request.method === "POST") {
    if (!isAdmin(auth)) {
      return apiError(403, "Forbidden");
    }
    try {
      const body = await readOptionalJsonBody<{
        owner?: string;
        force?: boolean;
      }>(request);
      const text = await memToolCall(
        env,
        "mem_migrate_legacy",
        { owner: body.owner ?? owner, force: body.force },
        auth,
        owner,
      );
      return new Response(text, {
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      return jsonError(e);
    }
  }

  if (url.pathname === "/v1/mem/reindex" && request.method === "POST") {
    if (!isAdmin(auth)) {
      return apiError(403, "Forbidden");
    }
    try {
      const body = await readOptionalJsonBody<{ owner?: string }>(request);
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
    } catch (e) {
      return jsonError(e);
    }
  }

  if (url.pathname === "/v1/mem/search" && request.method === "POST") {
    try {
      const body = await readJsonBody<{
        query?: string;
        top_k?: number;
        tag?: string;
        updated_after?: string;
        updated_before?: string;
      }>(request);
      const text = await memToolCall(
        env,
        "mem_search",
        {
          query: body.query,
          top_k: body.top_k,
          tag: body.tag,
          updated_after: body.updated_after,
          updated_before: body.updated_before,
          owner,
        },
        auth,
        owner,
      );
      return new Response(text, {
        headers: { "Content-Type": "application/json" },
      });
    } catch (e) {
      return jsonError(e);
    }
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
    try {
      const body = await readJsonBody<{
        content?: string;
        tags?: unknown;
        expires_at?: string;
      }>(request);
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
    } catch (e) {
      return jsonError(e);
    }
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
