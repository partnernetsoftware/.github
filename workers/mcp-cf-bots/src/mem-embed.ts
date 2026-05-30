import { memoryVectorId } from "./memory-store";

const EMBED_MODEL = "@cf/baai/bge-base-en-v1.5";

type EmbedResponse = { data?: number[][] };

export function ragEnabled(env: Env): boolean {
  return Boolean(env.AI && env.MEM_VECTORS);
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
  memId: string,
  key: string,
  content: string,
): Promise<void> {
  if (!env.MEM_VECTORS) {
    return;
  }
  const values = await embedText(env, `${key}\n${content}`);
  await env.MEM_VECTORS.upsert([
    {
      id: memoryVectorId(owner, memId),
      values,
      metadata: { owner, key, mem_id: memId },
    },
  ]);
}

export async function deleteMemoryVector(
  env: Env,
  owner: string,
  memId: string,
): Promise<void> {
  if (!env.MEM_VECTORS) {
    return;
  }
  await env.MEM_VECTORS.deleteByIds([memoryVectorId(owner, memId)]);
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
    topK,
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
