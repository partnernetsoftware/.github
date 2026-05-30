import { memoryLegacyStub, memoryStub } from "./memory-store";
import { putMemory } from "./mem-put";
import { reindexOwner } from "./mem-reindex";
import { vectorizeEnabled } from "./mem-embed";

export type MigrateLegacyResult = {
  owner: string;
  legacy_keys: number;
  imported: number;
  skipped: number;
  reindexed: number;
};

/** Copy entries from legacy MemoryDO blob into MemorySqliteDO. */
export async function migrateLegacyOwner(
  env: Env,
  owner: string,
  opts?: { reindex?: boolean; skip_existing?: boolean },
): Promise<MigrateLegacyResult> {
  if (!env.MEMORY_LEGACY) {
    throw new Error("MEMORY_LEGACY binding is not configured");
  }
  if (!env.MEMORY_STORE) {
    throw new Error("MEMORY_STORE binding is not configured");
  }

  const legacyRes = await memoryLegacyStub(env, owner).fetch(
    "https://memory.internal/export",
  );
  if (!legacyRes.ok) {
    throw new Error(await legacyRes.text());
  }
  const { entries } = (await legacyRes.json()) as {
    entries: Array<{
      key: string;
      content: string;
      tags?: string[];
    }>;
  };

  let skipped = 0;
  let imported = 0;

  if (opts?.skip_existing !== false) {
    const sqliteStats = await memoryStub(env, owner).fetch(
      "https://memory.internal/stats",
    );
    if (sqliteStats.ok) {
      const st = (await sqliteStats.json()) as { keys: number };
      if (st.keys > 0 && entries.length > 0) {
        return {
          owner,
          legacy_keys: entries.length,
          imported: 0,
          skipped: entries.length,
          reindexed: 0,
        };
      }
    }
  }

  for (const row of entries) {
    const key = String(row.key ?? "").trim();
    const content = String(row.content ?? "").trim();
    if (!key || !content) {
      skipped++;
      continue;
    }
    await putMemory(env, owner, key, content, { tags: row.tags });
    imported++;
  }

  let reindexed = 0;
  if (opts?.reindex !== false && vectorizeEnabled(env) && imported > 0) {
    const r = await reindexOwner(env, owner);
    reindexed = r.upserted;
  }

  return {
    owner,
    legacy_keys: entries.length,
    imported,
    skipped,
    reindexed,
  };
}
