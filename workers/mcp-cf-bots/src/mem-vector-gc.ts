import { trimOpt } from "./config";
import { loadVectorGcCursor, saveVectorGcCursor } from "./mem-cron-kv";
import { memCronGcPagesPerRun, vectorizeIndexName } from "./mem-config";
import { deleteMemoryVectors, vectorizeEnabled } from "./mem-embed";
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
    const msg = json.errors?.[0]?.message ?? `Vectorize API ${res.status}`;
    throw new Error(msg);
  }
  return json.result;
}

export async function listVectorizeIdsPage(
  env: Env,
  cursor?: string,
): Promise<{ ids: string[]; nextCursor?: string; done: boolean }> {
  const index = vectorizeIndexName(env);
  const query: Record<string, string> = { count: "1000" };
  if (cursor) {
    query.cursor = cursor;
  }
  const page = await cfApiFetch<ListVectorsResult>(env, index, query);
  const ids: string[] = [];
  for (const v of page.vectors ?? []) {
    if (v.id) {
      ids.push(v.id);
    }
  }
  const done = !page.isTruncated;
  return { ids, nextCursor: done ? undefined : page.nextCursor, done };
}

/** Full index scan (admin / one-off). Prefer incremental for cron. */
export async function listVectorizeIds(env: Env): Promise<string[]> {
  const ids: string[] = [];
  let cursor: string | undefined;
  let guard = 0;
  do {
    const page = await listVectorizeIdsPage(env, cursor);
    ids.push(...page.ids);
    cursor = page.nextCursor;
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

export type IncrementalGcResult = {
  results: VectorGcResult[];
  pages_processed: number;
  complete: boolean;
  cursor?: string;
};

/**
 * Paginated orphan GC — resumes from KV cursor between cron ticks.
 */
export async function gcOrphanVectorsIncremental(
  env: Env,
  owners: string[],
  opts?: { maxPages?: number; dryRun?: boolean },
): Promise<IncrementalGcResult> {
  const empty = owners.map((owner) => ({
    owner,
    scanned: 0,
    orphans: 0,
    deleted: 0,
    dry_run: Boolean(opts?.dryRun),
  }));

  if (!vectorizeEnabled(env) || owners.length === 0) {
    return { results: empty, pages_processed: 0, complete: true };
  }

  const ownerSet = new Set(owners);
  const validCache = new Map<string, Set<string>>();
  const pendingDeletes = new Map<string, string[]>();
  const tally = new Map(owners.map((o) => [o, { scanned: 0, orphans: 0 }]));

  let cursor = await loadVectorGcCursor(env);
  const maxPages = opts?.maxPages ?? memCronGcPagesPerRun(env);
  let pages = 0;

  while (pages < maxPages) {
    const page = await listVectorizeIdsPage(env, cursor);
    pages++;

    for (const fullId of page.ids) {
      const parsed = parseMemoryVectorId(fullId);
      if (!parsed || !ownerSet.has(parsed.owner)) {
        continue;
      }
      let valid = validCache.get(parsed.owner);
      if (!valid) {
        valid = await validChunkIdsForOwner(env, parsed.owner);
        validCache.set(parsed.owner, valid);
      }
      const t = tally.get(parsed.owner)!;
      t.scanned++;
      if (!valid.has(parsed.chunkId)) {
        t.orphans++;
        if (!opts?.dryRun) {
          const list = pendingDeletes.get(parsed.owner) ?? [];
          list.push(parsed.chunkId);
          pendingDeletes.set(parsed.owner, list);
        }
      }
    }

    if (page.done) {
      cursor = undefined;
      break;
    }
    cursor = page.nextCursor;
  }

  await saveVectorGcCursor(env, cursor);

  if (!opts?.dryRun) {
    for (const [owner, chunkIds] of pendingDeletes) {
      if (chunkIds.length > 0) {
        await deleteMemoryVectors(env, owner, chunkIds);
      }
    }
  }

  const results: VectorGcResult[] = owners.map((owner) => {
    const t = tally.get(owner)!;
    const deleted = opts?.dryRun ? 0 : (pendingDeletes.get(owner)?.length ?? 0);
    return {
      owner,
      scanned: t.scanned,
      orphans: t.orphans,
      deleted,
      dry_run: Boolean(opts?.dryRun),
    };
  });

  return {
    results,
    pages_processed: pages,
    complete: !cursor,
    cursor,
  };
}

/** Single-owner GC (scans index until complete or use incremental with high page limit). */
export async function gcOrphanVectors(
  env: Env,
  owner: string,
  opts?: { dryRun?: boolean },
): Promise<VectorGcResult> {
  const inc = await gcOrphanVectorsIncremental(env, [owner], {
    dryRun: opts?.dryRun,
    maxPages: 500,
  });
  return (
    inc.results[0] ?? {
      owner,
      scanned: 0,
      orphans: 0,
      deleted: 0,
      dry_run: Boolean(opts?.dryRun),
    }
  );
}

export async function gcOrphanVectorsAllOwners(
  env: Env,
  owners: string[],
  opts?: { dryRun?: boolean },
): Promise<VectorGcResult[]> {
  const inc = await gcOrphanVectorsIncremental(env, owners, {
    dryRun: opts?.dryRun,
    maxPages: memCronGcPagesPerRun(env),
  });
  return inc.results;
}
