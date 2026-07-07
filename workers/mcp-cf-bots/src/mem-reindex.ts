import { trimOpt } from "./config";
import { listUserTokens } from "./auth";
import { loadReindexWatermark, saveReindexWatermark } from "./mem-cron-kv";
import { maybeDecryptContent } from "./mem-crypto";
import { semanticRagEnabled, upsertMemoryVectors } from "./mem-embed";
import { memoryStub } from "./memory-store";

export type OwnerStats = {
  keys: number;
  chunks: number;
  bytes: number;
  max_updated_at: string | null;
};

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

export async function fetchOwnerStats(env: Env, owner: string): Promise<OwnerStats> {
  const res = await memoryStub(env, owner).fetch("https://memory.internal/stats");
  if (!res.ok) {
    throw new Error(await res.text());
  }
  return (await res.json()) as OwnerStats;
}

export async function ownerNeedsReindex(env: Env, owner: string): Promise<boolean> {
  const stats = await fetchOwnerStats(env, owner);
  if (stats.chunks === 0) {
    return false;
  }
  const wm = await loadReindexWatermark(env, owner);
  if (!wm) {
    return true;
  }
  const maxAt = stats.max_updated_at ?? "";
  return wm.max_updated_at !== maxAt || wm.chunks !== stats.chunks;
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

  const stats = await fetchOwnerStats(env, owner);
  if (stats.max_updated_at) {
    await saveReindexWatermark(env, owner, {
      max_updated_at: stats.max_updated_at,
      chunks: stats.chunks,
    });
  }

  return { upserted: items.length };
}

export async function reindexOwners(
  env: Env,
  owners: string[],
): Promise<Array<{ owner: string; upserted: number; skipped?: boolean; error?: string }>> {
  const out: Array<{
    owner: string;
    upserted: number;
    skipped?: boolean;
    error?: string;
  }> = [];
  for (const owner of owners) {
    try {
      if (!(await ownerNeedsReindex(env, owner))) {
        out.push({ owner, upserted: 0, skipped: true });
        continue;
      }
      const { upserted } = await reindexOwner(env, owner);
      out.push({ owner, upserted });
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      out.push({ owner, upserted: 0, error: message });
    }
  }
  return out;
}
