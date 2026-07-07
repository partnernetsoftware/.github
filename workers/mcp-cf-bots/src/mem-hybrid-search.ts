import {
  embedText,
  queryMemoryDoEmbed,
  queryMemoryVectors,
  ragBackend,
  semanticRagEnabled,
} from "./mem-embed";
import { mergeHybridResults, type SearchHit } from "./mem-hybrid";
import type { MemoryRecord } from "./memory-do";

export type MemSearchFilters = {
  tag?: string;
  updated_after?: string;
  updated_before?: string;
};

/** FTS + Vectorize / DO-embed hybrid retrieval (shared by MCP tools and REST). */
export async function runHybridSearch(
  env: Env,
  stub: DurableObjectStub,
  _owner: string,
  query: string,
  topK: number,
  filters?: MemSearchFilters,
): Promise<{ matches: SearchHit[]; mode: string }> {
  const vectorHits: SearchHit[] = [];
  const keywordHits: SearchHit[] = [];

  if (ragBackend(env) === "vectorize") {
    try {
      const hits = await queryMemoryVectors(env, _owner, query, topK);
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
