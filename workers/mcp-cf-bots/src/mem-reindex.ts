import { trimOpt } from "./config";
import { listUserTokens } from "./auth";
import { maybeDecryptContent } from "./mem-crypto";
import { semanticRagEnabled, upsertMemoryVectors } from "./mem-embed";
import { memoryStub } from "./memory-store";

/** Distinct owner namespaces for cron / maintenance. */
export async function listMemOwners(env: Env): Promise<string[]> {
  const owners = new Set<string>();
  const def = trimOpt(env.DEFAULT_OWNER);
  if (def) {
    owners.add(def);
  }
  const extra = trimOpt(env.MEM_CRON_OWNERS);
  if (extra) {
    for (const part of extra.split(",")) {
      const o = part.trim();
      if (o) {
        owners.add(o);
      }
    }
  }
  if (env.TOKENS) {
    try {
      const tokens = await listUserTokens(env);
      for (const t of tokens) {
        owners.add(t.owner);
      }
    } catch {
      /* KV optional in dev */
    }
  }
  return [...owners].sort();
}

/** Rebuild Vectorize rows from MemorySqliteDO chunks for one owner. */
export async function reindexOwner(
  env: Env,
  owner: string,
): Promise<{ upserted: number }> {
  const stub = memoryStub(env, owner);
  const res = await stub.fetch("https://memory.internal/export");
  if (!res.ok) {
    throw new Error(await res.text());
  }
  const { chunks } = (await res.json()) as {
    chunks: Array<{ id: string; key: string; chunk_index: number; content: string }>;
  };
  if (!env.MEM_VECTORS || !semanticRagEnabled(env)) {
    return { upserted: 0 };
  }
  const items: Array<{ chunkId: string; key: string; content: string; chunkIndex: number }> =
    [];
  for (const c of chunks) {
    const plain = await maybeDecryptContent(env, c.content);
    items.push({
      chunkId: c.id,
      key: c.key,
      content: plain,
      chunkIndex: c.chunk_index,
    });
  }
  await upsertMemoryVectors(env, owner, items);
  return { upserted: items.length };
}

export async function reindexOwners(
  env: Env,
  owners: string[],
): Promise<Array<{ owner: string; upserted: number; error?: string }>> {
  const out: Array<{ owner: string; upserted: number; error?: string }> = [];
  for (const owner of owners) {
    try {
      const { upserted } = await reindexOwner(env, owner);
      out.push({ owner, upserted });
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      out.push({ owner, upserted: 0, error: message });
    }
  }
  return out;
}
