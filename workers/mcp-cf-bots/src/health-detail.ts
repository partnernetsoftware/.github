import { trimOpt } from "./config";
import { loadCronReport } from "./mem-cron";
import {
  cfVectorGcReady,
  memCronReindexEnabled,
  memCronVectorGcEnabled,
  memEncryptAtRest,
} from "./mem-config";
import { ragBackend, semanticRagEnabled } from "./mem-embed";

export type HealthFeatures = {
  memory: boolean;
  rag: boolean;
  rag_backend: string;
  mem_encrypt: boolean;
  cron_reindex: boolean;
  cron_vector_gc: boolean;
  cf_api_ready: boolean;
  memory_legacy: boolean;
};

export type HealthCronLast = {
  available: boolean;
  at?: string;
  owners?: number;
  reindex_upserted?: number;
  gc_deleted?: number;
  gc_complete?: boolean;
};

export async function buildHealthFeatures(env: Env): Promise<{
  features: HealthFeatures;
  cron_last: HealthCronLast;
}> {
  const cronReport = await loadCronReport(env);
  const cronLast: HealthCronLast = cronReport
    ? {
        available: true,
        at: cronReport.at,
        owners: cronReport.owners.length,
        reindex_upserted: cronReport.reindex.reduce(
          (n, r) => n + (r.skipped ? 0 : r.upserted),
          0,
        ),
        gc_deleted: cronReport.vector_gc.reduce((n, r) => n + r.deleted, 0),
        gc_complete: cronReport.vector_gc_meta?.complete,
      }
    : { available: false };

  return {
    features: {
      memory: Boolean(env.MEMORY_STORE),
      rag: semanticRagEnabled(env),
      rag_backend: ragBackend(env),
      mem_encrypt: memEncryptAtRest(env),
      cron_reindex: memCronReindexEnabled(env),
      cron_vector_gc: memCronVectorGcEnabled(env) && cfVectorGcReady(env),
      cf_api_ready: cfVectorGcReady(env),
      memory_legacy: Boolean(env.MEMORY_LEGACY),
    },
    cron_last: cronLast,
  };
}

export function customDomainHint(env: Env): string | null {
  const host = trimOpt(env.MCP_PUBLIC_HOST);
  return host ? `Public MCP host: https://${host.replace(/^https?:\/\//, "")}` : null;
}
