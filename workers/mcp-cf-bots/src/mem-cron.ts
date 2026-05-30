import {
  memCronOwnerLimit,
  memCronReindexEnabled,
  memCronVectorGcEnabled,
  cfVectorGcReady,
} from "./mem-config";
import { listMemOwners, reindexOwners } from "./mem-reindex";
import { gcOrphanVectorsAllOwners } from "./mem-vector-gc";

export type MemCronReport = {
  at: string;
  owners: string[];
  reindex: Array<{ owner: string; upserted: number; error?: string }>;
  vector_gc: Array<{
    owner: string;
    scanned: number;
    orphans: number;
    deleted: number;
    dry_run: boolean;
  }>;
};

/** Daily cron: optional reindex + orphan Vectorize GC per owner. */
export async function runMemCron(env: Env): Promise<MemCronReport> {
  const report: MemCronReport = {
    at: new Date().toISOString(),
    owners: [],
    reindex: [],
    vector_gc: [],
  };

  if (!env.MEMORY_STORE) {
    return report;
  }

  const reindexOn = memCronReindexEnabled(env);
  const gcOn = memCronVectorGcEnabled(env) && cfVectorGcReady(env);
  if (!reindexOn && !gcOn) {
    return report;
  }

  const owners = (await listMemOwners(env)).slice(0, memCronOwnerLimit(env));
  report.owners = owners;

  if (reindexOn) {
    report.reindex = await reindexOwners(env, owners);
  }

  if (gcOn) {
    report.vector_gc = await gcOrphanVectorsAllOwners(env, owners, {
      dryRun: false,
    });
  }

  return report;
}
