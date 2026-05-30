import {
  memCronOwnerLimit,
  memCronReindexEnabled,
  memCronVectorGcEnabled,
  cfVectorGcReady,
} from "./mem-config";
import { loadCronReport, postCronWebhook, saveCronReport } from "./mem-cron-kv";
import { listMemOwners, reindexOwners } from "./mem-reindex";
import { gcOrphanVectorsIncremental } from "./mem-vector-gc";

export type MemCronReport = {
  at: string;
  owners: string[];
  reindex: Array<{
    owner: string;
    upserted: number;
    skipped?: boolean;
    error?: string;
  }>;
  vector_gc: Array<{
    owner: string;
    scanned: number;
    orphans: number;
    deleted: number;
    dry_run: boolean;
  }>;
  vector_gc_meta?: {
    pages_processed: number;
    complete: boolean;
    cursor?: string;
  };
};

/** Daily cron: incremental reindex + paginated orphan Vectorize GC. */
export async function runMemCron(env: Env): Promise<MemCronReport> {
  const report: MemCronReport = {
    at: new Date().toISOString(),
    owners: [],
    reindex: [],
    vector_gc: [],
  };

  if (!env.MEMORY_STORE) {
    await saveCronReport(env, report);
    return report;
  }

  const reindexOn = memCronReindexEnabled(env);
  const gcOn = memCronVectorGcEnabled(env) && cfVectorGcReady(env);
  if (!reindexOn && !gcOn) {
    await saveCronReport(env, report);
    return report;
  }

  const owners = (await listMemOwners(env)).slice(0, memCronOwnerLimit(env));
  report.owners = owners;

  if (reindexOn) {
    report.reindex = await reindexOwners(env, owners);
  }

  if (gcOn) {
    const inc = await gcOrphanVectorsIncremental(env, owners, { dryRun: false });
    report.vector_gc = inc.results;
    report.vector_gc_meta = {
      pages_processed: inc.pages_processed,
      complete: inc.complete,
      cursor: inc.cursor,
    };
  }

  await saveCronReport(env, report);
  await postCronWebhook(env, report);
  return report;
}

export { loadCronReport };
