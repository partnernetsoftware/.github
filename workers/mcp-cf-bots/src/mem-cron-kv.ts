import type { MemCronReport } from "./mem-cron";

const REPORT_KEY = "cron:report:latest";
const VGC_CURSOR_KEY = "cron:vgc:cursor";
const REINDEX_WM_PREFIX = "cron:reindex:wm:";

export async function loadCronReport(env: Env): Promise<MemCronReport | null> {
  if (!env.TOKENS) {
    return null;
  }
  const raw = await env.TOKENS.get(REPORT_KEY);
  if (!raw) {
    return null;
  }
  try {
    return JSON.parse(raw) as MemCronReport;
  } catch {
    return null;
  }
}

export async function saveCronReport(env: Env, report: MemCronReport): Promise<void> {
  if (!env.TOKENS) {
    return;
  }
  await env.TOKENS.put(REPORT_KEY, JSON.stringify(report), {
    expirationTtl: 60 * 60 * 24 * 14,
  });
}

export async function loadVectorGcCursor(env: Env): Promise<string | undefined> {
  if (!env.TOKENS) {
    return undefined;
  }
  const raw = await env.TOKENS.get(VGC_CURSOR_KEY);
  return raw?.trim() || undefined;
}

export async function saveVectorGcCursor(
  env: Env,
  cursor: string | undefined,
): Promise<void> {
  if (!env.TOKENS) {
    return;
  }
  if (!cursor) {
    await env.TOKENS.delete(VGC_CURSOR_KEY);
    return;
  }
  await env.TOKENS.put(VGC_CURSOR_KEY, cursor, {
    expirationTtl: 60 * 60 * 24 * 7,
  });
}

export type ReindexWatermark = { max_updated_at: string; chunks: number };

export async function loadReindexWatermark(
  env: Env,
  owner: string,
): Promise<ReindexWatermark | null> {
  if (!env.TOKENS) {
    return null;
  }
  const raw = await env.TOKENS.get(`${REINDEX_WM_PREFIX}${owner}`);
  if (!raw) {
    return null;
  }
  try {
    return JSON.parse(raw) as ReindexWatermark;
  } catch {
    return null;
  }
}

export async function saveReindexWatermark(
  env: Env,
  owner: string,
  wm: ReindexWatermark,
): Promise<void> {
  if (!env.TOKENS) {
    return;
  }
  await env.TOKENS.put(`${REINDEX_WM_PREFIX}${owner}`, JSON.stringify(wm), {
    expirationTtl: 60 * 60 * 24 * 30,
  });
}

export async function postCronWebhook(env: Env, report: MemCronReport): Promise<void> {
  const url = env.MEM_CRON_WEBHOOK_URL?.trim();
  if (!url) {
    return;
  }
  try {
    await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ event: "mem_cron", ...report }),
    });
  } catch (e) {
    console.error("cron webhook failed", e);
  }
}
