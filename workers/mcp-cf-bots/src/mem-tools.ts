import type { AuthContext } from "./auth";
import { isAdmin } from "./auth";
import { ownerForTool } from "./owner-scope";
import { checkMemRateLimit } from "./rate-limit";
import {
  deleteMemoryVectors,
  embedText,
  queryMemoryDoEmbed,
  queryMemoryVectors,
  ragBackend,
  semanticRagEnabled,
} from "./mem-embed";
import { mergeHybridResults, type SearchHit } from "./mem-hybrid";
import { migrateLegacyOwner } from "./mem-migrate";
import { putMemory } from "./mem-put";
import { reindexOwner } from "./mem-reindex";
import { gcOrphanVectors, gcOrphanVectorsIncremental } from "./mem-vector-gc";
import type { MemoryRecord } from "./memory-do";
import { memoryStub } from "./memory-store";
import { validateKey } from "./validate";

export { reindexOwner, listMemOwners, reindexOwners } from "./mem-reindex";
export { gcOrphanVectors, gcOrphanVectorsAllOwners } from "./mem-vector-gc";
export { runMemCron } from "./mem-cron";

type MemSearchFilters = {
  tag?: string;
  updated_after?: string;
  updated_before?: string;
};

async function hybridSearch(
  env: Env,
  stub: DurableObjectStub,
  owner: string,
  query: string,
  topK: number,
  filters?: MemSearchFilters,
): Promise<{ matches: SearchHit[]; mode: string }> {
  const vectorHits: SearchHit[] = [];
  const keywordHits: SearchHit[] = [];

  if (ragBackend(env) === "vectorize") {
    try {
      const hits = await queryMemoryVectors(env, owner, query, topK);
      for (const hit of hits) {
        const gr = await stub.fetch(
          `https://memory.internal/entry/${encodeURIComponent(hit.key)}`,
        );
        if (!gr.ok) {
          continue;
        }
        const rec = (await gr.json()) as MemoryRecord;
        vectorHits.push({
          id: hit.mem_id,
          key: hit.key,
          score: hit.score,
          content: rec.content,
          tags: rec.tags,
          updated_at: rec.updated_at,
          source: "vector",
        });
      }
    } catch {
      /* continue */
    }
  }

  const kwRes = await stub.fetch("https://memory.internal/search", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query, top_k: topK, ...filters }),
  });
  if (kwRes.ok) {
    const kw = (await kwRes.json()) as { matches: SearchHit[] };
    for (const m of kw.matches) {
      keywordHits.push({ ...m, source: "keyword" });
    }
  }

  if (vectorHits.length === 0 && semanticRagEnabled(env)) {
    try {
      const qEmbed = await embedText(env, query);
      const doHits = await queryMemoryDoEmbed(stub, qEmbed, topK);
      for (const m of doHits) {
        vectorHits.push({ ...m, source: "vector" });
      }
    } catch {
      /* ignore */
    }
  }

  if (vectorHits.length > 0 || keywordHits.length > 0) {
    const merged = mergeHybridResults(vectorHits, keywordHits, topK);
    return { matches: merged, mode: "hybrid" };
  }

  return { matches: [], mode: "hybrid" };
}

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
    await checkMemRateLimit(env, owner, "mem_search");
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
    const { matches, mode } = await hybridSearch(env, stub, owner, query, topK, filters);
    return JSON.stringify({ matches, mode }, null, 2);
  }

  if (name === "mem_import") {
    const entries = args.entries;
    if (!Array.isArray(entries)) {
      throw new Error("entries array is required");
    }
    await checkMemRateLimit(env, owner, "mem_import");
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

  if (name === "mem_migrate_legacy") {
    if (!isAdmin(auth)) {
      throw new Error("forbidden: admin token required");
    }
    const target =
      typeof args.owner === "string" && args.owner.trim()
        ? args.owner.trim()
        : owner;
    const force = args.force === true || args.force === "true";
    const result = await migrateLegacyOwner(env, target, {
      skip_existing: !force,
      reindex: true,
    });
    return JSON.stringify(result, null, 2);
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
    await checkMemRateLimit(env, owner, "mem_put");
    const content = String(args.content ?? "").trim();
    if (!content) {
      throw new Error("content is required");
    }
    const tags = Array.isArray(args.tags) ? args.tags.map(String) : undefined;
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
    const res = await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(key)}`,
    );
    if (res.status === 404) {
      throw new Error(`memory not found: ${key}`);
    }
    return res.text();
  }

  if (name === "mem_delete") {
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
