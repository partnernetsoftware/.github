import { trimOpt } from "./config";
import { deleteMemoryVectors, vectorizeEnabled } from "./mem-embed";
import { vectorizeIndexName } from "./mem-config";
import { memoryStub, parseMemoryVectorId } from "./memory-store";

type ListVectorsResult = {
  vectors: Array<{ id: string }>;
  isTruncated: boolean;
  nextCursor?: string;
};

async function cfApiFetch<T>(env: Env, path: string, query?: Record<string, string>): Promise<T> {
  const accountId = trimOpt(env.CF_ACCOUNT_ID);
  const token = trimOpt(env.CF_API_TOKEN);
  if (!accountId || !token) {
    throw new Error("CF_ACCOUNT_ID and CF_API_TOKEN required for Vectorize list API");
  }
  const url = new URL(
    `https://api.cloudflare.com/client/v4/accounts/${accountId}/vectorize/v2/indexes/${encodeURIComponent(path)}/list`,
  );
  if (query) {
    for (const [k, v] of Object.entries(query)) {
      url.searchParams.set(k, v);
    }
  }
  const res = await fetch(url.toString(), {
    headers: { Authorization: `Bearer ${token}` },
  });
  const json = (await res.json()) as {
    success?: boolean;
    errors?: Array<{ message?: string }>;
    result?: T;
  };
  if (!res.ok || !json.success || !json.result) {
    const msg =
      json.errors?.[0]?.message ?? `Vectorize API ${res.status}`;
    throw new Error(msg);
  }
  return json.result;
}

/** Paginated list of all vector ids in the bound index (REST API). */
export async function listVectorizeIds(env: Env): Promise<string[]> {
  const index = vectorizeIndexName(env);
  const ids: string[] = [];
  let cursor: string | undefined;
  let guard = 0;
  do {
    const query: Record<string, string> = { count: "1000" };
    if (cursor) {
      query.cursor = cursor;
    }
    const page = await cfApiFetch<ListVectorsResult>(env, index, query);
    for (const v of page.vectors ?? []) {
      if (v.id) {
        ids.push(v.id);
      }
    }
    cursor = page.isTruncated ? page.nextCursor : undefined;
    guard++;
    if (guard > 500) {
      throw new Error("vectorize list pagination guard exceeded");
    }
  } while (cursor);
  return ids;
}

async function validChunkIdsForOwner(env: Env, owner: string): Promise<Set<string>> {
  const stub = memoryStub(env, owner);
  const res = await stub.fetch("https://memory.internal/export");
  if (!res.ok) {
    throw new Error(await res.text());
  }
  const { chunks } = (await res.json()) as { chunks: Array<{ id: string }> };
  return new Set(chunks.map((c) => c.id));
}

export type VectorGcResult = {
  owner: string;
  scanned: number;
  orphans: number;
  deleted: number;
  dry_run: boolean;
};

/**
 * Remove Vectorize rows whose chunk id no longer exists in MemorySqliteDO.
 * Requires CF_ACCOUNT_ID + CF_API_TOKEN (Vectorize Read/Edit).
 */
export async function gcOrphanVectors(
  env: Env,
  owner: string,
  opts?: { dryRun?: boolean },
): Promise<VectorGcResult> {
  if (!vectorizeEnabled(env)) {
    return { owner, scanned: 0, orphans: 0, deleted: 0, dry_run: Boolean(opts?.dryRun) };
  }
  const valid = await validChunkIdsForOwner(env, owner);
  const allIds = await listVectorizeIds(env);
  const ownerPrefix = `${owner}::`;
  const orphanChunkIds: string[] = [];

  for (const fullId of allIds) {
    if (!fullId.startsWith(ownerPrefix)) {
      continue;
    }
    const parsed = parseMemoryVectorId(fullId);
    if (!parsed || parsed.owner !== owner) {
      continue;
    }
    if (!valid.has(parsed.chunkId)) {
      orphanChunkIds.push(parsed.chunkId);
    }
  }

  const dryRun = Boolean(opts?.dryRun);
  if (!dryRun && orphanChunkIds.length > 0) {
    await deleteMemoryVectors(env, owner, orphanChunkIds);
  }

  return {
    owner,
    scanned: allIds.filter((id) => id.startsWith(ownerPrefix)).length,
    orphans: orphanChunkIds.length,
    deleted: dryRun ? 0 : orphanChunkIds.length,
    dry_run: dryRun,
  };
}

export async function gcOrphanVectorsAllOwners(
  env: Env,
  owners: string[],
  opts?: { dryRun?: boolean },
): Promise<VectorGcResult[]> {
  const out: VectorGcResult[] = [];
  for (const owner of owners) {
    try {
      out.push(await gcOrphanVectors(env, owner, opts));
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      out.push({
        owner,
        scanned: 0,
        orphans: 0,
        deleted: 0,
        dry_run: Boolean(opts?.dryRun),
      });
      console.error(`gcOrphanVectors ${owner}: ${message}`);
    }
  }
  return out;
}
