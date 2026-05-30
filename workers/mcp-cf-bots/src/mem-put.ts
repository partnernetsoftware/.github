import { memMaxBytes, memMaxKeys } from "./mem-config";
import { splitForStorage } from "./mem-chunk";
import {
  deleteMemoryVectors,
  embedText,
  semanticRagEnabled,
  upsertMemoryVectors,
} from "./mem-embed";
import type { MemoryRecord } from "./memory-do";
import { memoryStub } from "./memory-store";

type PutResult = MemoryRecord & { replaced_chunk_ids?: string[] };

/** Store memory (chunked DO + optional Vectorize). Shared by tools and migration. */
export async function putMemory(
  env: Env,
  owner: string,
  key: string,
  content: string,
  opts?: { tags?: string[]; expires_at?: string },
): Promise<PutResult> {
  const stub = memoryStub(env, owner);
  const parts = splitForStorage(content, env);
  const chunkPayloads: Array<{ content: string; embedding?: number[] }> = [];

  for (const part of parts) {
    let embedding: number[] | undefined;
    if (semanticRagEnabled(env)) {
      try {
        embedding = await embedText(env, `${key}\n${part.text}`);
      } catch {
        embedding = undefined;
      }
    }
    chunkPayloads.push({ content: part.text, embedding });
  }

  const res = await stub.fetch(
    `https://memory.internal/entry/${encodeURIComponent(key)}`,
    {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        chunks: chunkPayloads,
        tags: opts?.tags,
        expires_at: opts?.expires_at,
        quota: { max_keys: memMaxKeys(env), max_bytes: memMaxBytes(env) },
      }),
    },
  );
  if (!res.ok) {
    throw new Error(await res.text());
  }
  const rec = (await res.json()) as PutResult;
  const chunkIds = rec.chunk_ids ?? [rec.id];
  if (rec.replaced_chunk_ids?.length) {
    try {
      await deleteMemoryVectors(env, owner, rec.replaced_chunk_ids);
    } catch {
      /* ignore */
    }
  }
  if (env.MEM_VECTORS && semanticRagEnabled(env)) {
    try {
      await upsertMemoryVectors(
        env,
        owner,
        parts.map((p, i) => ({
          chunkId: chunkIds[i] ?? rec.id,
          key,
          content: p.text,
          chunkIndex: p.index,
        })),
      );
    } catch {
      /* DO still ok */
    }
  }
  return rec;
}
