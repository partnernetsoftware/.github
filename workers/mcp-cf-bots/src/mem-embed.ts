import { memoryVectorId } from "./memory-store";

const EMBED_MODEL = "@cf/baai/bge-base-en-v1.5";

type EmbedResponse = { data?: number[][] };

export type RagBackend = "vectorize" | "do_embed" | "keyword";

export function ragBackend(env: Env): RagBackend {
  if (env.AI && env.MEM_VECTORS) {
    return "vectorize";
  }
  if (env.AI) {
    return "do_embed";
  }
  return "keyword";
}

export function semanticRagEnabled(env: Env): boolean {
  return Boolean(env.AI);
}

export function vectorizeEnabled(env: Env): boolean {
  return Boolean(env.MEM_VECTORS);
}

export function ragEnabled(env: Env): boolean {
  return semanticRagEnabled(env);
}

export async function embedText(env: Env, text: string): Promise<number[]> {
  if (!env.AI) {
    throw new Error("Workers AI is not configured");
  }
  const response = (await env.AI.run(EMBED_MODEL, {
    text: [text.slice(0, 8000)],
  })) as EmbedResponse;
  const row = response.data?.[0];
  if (!row?.length) {
    throw new Error("embedding failed");
  }
  return row;
}

export async function upsertMemoryVector(
  env: Env,
  owner: string,
  chunkId: string,
  key: string,
  content: string,
  chunkIndex = 0,
): Promise<void> {
  if (!env.MEM_VECTORS) {
    return;
  }
  const values = await embedText(env, `${key}\n${content}`);
  await env.MEM_VECTORS.upsert([
    {
      id: memoryVectorId(owner, chunkId),
      values,
      metadata: { owner, key, mem_id: chunkId, chunk_index: chunkIndex },
    },
  ]);
}

export async function upsertMemoryVectors(
  env: Env,
  owner: string,
  items: Array<{ chunkId: string; key: string; content: string; chunkIndex: number }>,
): Promise<void> {
  if (!env.MEM_VECTORS || items.length === 0) {
    return;
  }
  const vectors = [];
  for (const item of items) {
    const values = await embedText(env, `${item.key}\n${item.content}`);
    vectors.push({
      id: memoryVectorId(owner, item.chunkId),
      values,
      metadata: {
        owner,
        key: item.key,
        mem_id: item.chunkId,
        chunk_index: item.chunkIndex,
      },
    });
  }
  await env.MEM_VECTORS.upsert(vectors);
}

export async function deleteMemoryVectors(
  env: Env,
  owner: string,
  chunkIds: string[],
): Promise<void> {
  if (!env.MEM_VECTORS || chunkIds.length === 0) {
    return;
  }
  await env.MEM_VECTORS.deleteByIds(chunkIds.map((id) => memoryVectorId(owner, id)));
}

export async function queryMemoryVectors(
  env: Env,
  owner: string,
  query: string,
  topK: number,
): Promise<
  Array<{
    id: string;
    key: string;
    mem_id: string;
    score: number;
  }>
> {
  if (!env.MEM_VECTORS || !env.AI) {
    return [];
  }
  const values = await embedText(env, query);
  const result = await env.MEM_VECTORS.query(values, {
    topK: topK * 2,
    returnMetadata: "all",
    filter: { owner },
  });
  return (result.matches ?? []).map((m) => ({
    id: m.id,
    key: String(m.metadata?.key ?? ""),
    mem_id: String(m.metadata?.mem_id ?? ""),
    score: m.score,
  }));
}

export async function queryMemoryDoEmbed(
  stub: DurableObjectStub,
  queryEmbedding: number[],
  topK: number,
): Promise<
  Array<{
    id: string;
    key: string;
    score: number;
    content: string;
    tags?: string[];
    updated_at: string;
  }>
> {
  const res = await stub.fetch("https://memory.internal/search_semantic", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ embedding: queryEmbedding, top_k: topK }),
  });
  if (!res.ok) {
    throw new Error(await res.text());
  }
  const json = (await res.json()) as {
    matches: Array<{
      id: string;
      key: string;
      score: number;
      content: string;
      tags?: string[];
      updated_at: string;
    }>;
  };
  return json.matches;
}
