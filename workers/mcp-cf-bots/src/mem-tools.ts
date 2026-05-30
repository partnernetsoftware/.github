import type { AuthContext } from "./auth";
import { isAdmin } from "./auth";
import { ownerForTool } from "./owner-scope";
import { checkOwnerRateLimit } from "./rate-limit";
import { deleteMemoryVectors, ragBackend } from "./mem-embed";
import type { MemoryRecord } from "./memory-do";
import { runHybridSearch, type MemSearchFilters } from "./mem-hybrid-search";
import { putMemory } from "./mem-put";
import { reindexOwner } from "./mem-reindex";
import { gcOrphanVectors, gcOrphanVectorsIncremental } from "./mem-vector-gc";
import { memoryStub } from "./memory-store";
import { normalizeMemTags } from "./context-model";
import { validateKey } from "./validate";

export { reindexOwner, listMemOwners, reindexOwners } from "./mem-reindex";
export { gcOrphanVectors, gcOrphanVectorsAllOwners } from "./mem-vector-gc";
export { runMemCron } from "./mem-cron";

/** MCP `mem_*` tool handlers. */
export async function memToolCall(
  env: Env,
  name: string,
  args: Record<string, unknown>,
  auth: AuthContext,
  requestOwner: string,
): Promise<string> {
  const owner = ownerForTool(auth, env, args, requestOwner);
  const stub = memoryStub(env, owner);

  if (name === "mem_list") {
    await checkOwnerRateLimit(env, owner, "mem_list");
    const url = new URL("https://memory.internal/entries");
    if (typeof args.tag === "string" && args.tag) {
      url.searchParams.set("tag", args.tag);
    }
    return (await stub.fetch(url.toString())).text();
  }

  if (name === "mem_search") {
    const query = String(args.query ?? "").trim();
    if (!query) {
      throw new Error("query is required");
    }
    await checkOwnerRateLimit(env, owner, "mem_search");
    const topK = Math.min(Math.max(Number(args.top_k) || 5, 1), 20);
    const filters: MemSearchFilters = {};
    if (typeof args.tag === "string" && args.tag.trim()) {
      filters.tag = args.tag.trim();
    }
    if (typeof args.updated_after === "string" && args.updated_after.trim()) {
      filters.updated_after = args.updated_after.trim();
    }
    if (typeof args.updated_before === "string" && args.updated_before.trim()) {
      filters.updated_before = args.updated_before.trim();
    }
    const { matches, mode } = await runHybridSearch(env, stub, owner, query, topK, filters);
    return JSON.stringify({ matches, mode }, null, 2);
  }

  if (name === "mem_import") {
    const entries = args.entries;
    if (!Array.isArray(entries)) {
      throw new Error("entries array is required");
    }
    await checkOwnerRateLimit(env, owner, "mem_import");
    let ok = 0;
    for (const raw of entries) {
      const row = raw as Record<string, unknown>;
      const key = validateKey("key", String(row.key ?? ""));
      const content = String(row.content ?? "").trim();
      if (!content) {
        continue;
      }
      const tags = Array.isArray(row.tags) ? row.tags.map(String) : undefined;
      const expires_at =
        typeof row.expires_at === "string" ? row.expires_at : undefined;
      await putMemory(env, owner, key, content, { tags, expires_at });
      ok++;
    }
    return JSON.stringify({ ok: true, imported: ok }, null, 2);
  }

  if (name === "mem_reindex") {
    if (!isAdmin(auth)) {
      throw new Error("forbidden: admin token required");
    }
    const target =
      typeof args.owner === "string" && args.owner.trim()
        ? args.owner.trim()
        : owner;
    const result = await reindexOwner(env, target);
    return JSON.stringify(result, null, 2);
  }

  if (name === "mem_stats") {
    if (!isAdmin(auth)) {
      throw new Error("forbidden: admin token required");
    }
    const target =
      typeof args.owner === "string" && args.owner.trim()
        ? args.owner.trim()
        : owner;
    const res = await memoryStub(env, target).fetch("https://memory.internal/stats");
    return res.text();
  }

  if (name === "mem_vector_gc") {
    if (!isAdmin(auth)) {
      throw new Error("forbidden: admin token required");
    }
    const target =
      typeof args.owner === "string" && args.owner.trim()
        ? args.owner.trim()
        : owner;
    const dryRun = args.dry_run === true || args.dry_run === "true";
    const result = await gcOrphanVectors(env, target, { dryRun });
    return JSON.stringify(result, null, 2);
  }

  const key = validateKey("key", String(args.key ?? ""));

  if (name === "mem_put") {
    await checkOwnerRateLimit(env, owner, "mem_put");
    const content = String(args.content ?? "").trim();
    if (!content) {
      throw new Error("content is required");
    }
    const kind = typeof args.kind === "string" ? args.kind.trim() : undefined;
    const tags = normalizeMemTags(
      Array.isArray(args.tags) ? args.tags.map(String) : undefined,
      kind,
    );
    const expires_at =
      typeof args.expires_at === "string" ? args.expires_at : undefined;
    const rec = await putMemory(env, owner, key, content, { tags, expires_at });
    return JSON.stringify(
      {
        ok: true,
        id: rec.id,
        key: rec.key,
        chunks: rec.chunks,
        rag_backend: ragBackend(env),
      },
      null,
      2,
    );
  }

  if (name === "mem_get") {
    await checkOwnerRateLimit(env, owner, "mem_get");
    const res = await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(key)}`,
    );
    if (res.status === 404) {
      throw new Error(`memory not found: ${key}`);
    }
    return res.text();
  }

  if (name === "mem_delete") {
    await checkOwnerRateLimit(env, owner, "mem_delete");
    const getRes = await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(key)}`,
    );
    if (getRes.status === 404) {
      throw new Error(`memory not found: ${key}`);
    }
    const existing = (await getRes.json()) as MemoryRecord;
    const res = await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(key)}`,
      { method: "DELETE" },
    );
    const body = (await res.json()) as { deleted_chunk_ids?: string[] };
    await deleteMemoryVectors(env, owner, body.deleted_chunk_ids ?? existing.chunk_ids ?? [existing.id]);
    return JSON.stringify(body, null, 2);
  }

  throw new Error(`Unknown mem tool: ${name}`);
}
