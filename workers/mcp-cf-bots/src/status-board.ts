import { mcpHttpPath, mcpServerInfo, trimOpt } from "./config";
import { fetchWorkerUsageCached } from "./cf-analytics";
import { buildHealthFeatures, customDomainHint, type HealthCronLast, type HealthFeatures } from "./health-detail";
import { jsonResponse } from "./http-util";

export type StatusPayload = {
  ok: boolean;
  service: string;
  version: string;
  description: string;
  time: string;
  features: HealthFeatures;
  hint?: string;
  bindings: {
    session_store: boolean;
    registry: boolean;
    memory_store: boolean;
    tokens_kv: boolean;
    workers_ai: boolean;
    vectorize: boolean;
  };
  routes: {
    public: string[];
    authenticated: string[];
  };
  usage_24h: {
    available: boolean;
    cached?: boolean;
    hint?: string;
    error?: string;
    data?: {
      requests: number;
      errors: number;
      subrequests: number;
      cpu_time_ms: { p50: number | null; p99: number | null };
      period: { start: string; end: string };
      script: string;
    };
  };
  notes: string[];
  cron_last: HealthCronLast;
};

export async function buildStatusPayload(env: Env): Promise<StatusPayload> {
  let name = "mcp-cf-bots";
  let version = "unknown";
  let description = "";
  try {
    const info = mcpServerInfo(env);
    name = info.name;
    version = info.version;
    description = info.description;
  } catch {
    /* partial env */
  }

  let mcpPath = "/mcp";
  try {
    mcpPath = mcpHttpPath(env);
  } catch {
    /* default */
  }

  const [{ features, cron_last }, usageResult] = await Promise.all([
    buildHealthFeatures(env),
    fetchWorkerUsageCached(env),
  ]);
  const hint = customDomainHint(env);
  const hasCfCreds = Boolean(trimOpt(env.CF_ACCOUNT_ID) && trimOpt(env.CF_API_TOKEN));

  const notes = [
    "Root and /health are public. MCP, REST, and admin APIs require Bearer token.",
    "CPU metrics are Worker isolate CPU (not wall clock). Storage (DO/KV) totals are in the Cloudflare dashboard.",
  ];

  if (!hasCfCreds) {
    notes.push(
      "Set wrangler secrets CF_ACCOUNT_ID and CF_API_TOKEN (Analytics Read) to show 24h usage here.",
    );
  }

  return {
    ok: true,
    service: name,
    version,
    description,
    time: new Date().toISOString(),
    features,
    bindings: {
      session_store: Boolean(env.SESSION_STORE),
      registry: Boolean(env.REGISTRY),
      memory_store: Boolean(env.MEMORY_STORE),
      tokens_kv: Boolean(env.TOKENS),
      workers_ai: Boolean(env.AI),
      vectorize: Boolean(env.MEM_VECTORS),
    },
    routes: {
      public: ["/", "/health"],
      authenticated: [
        mcpPath,
        "/v1/me",
        "/v1/sessions",
        "/v1/session/*",
        "/v1/mem",
        "/v1/mem/*",
        "/v1/admin/*",
      ],
    },
    usage_24h: usageResult.usage
      ? {
          available: true,
          cached: usageResult.cached,
          data: {
            requests: usageResult.usage.requests,
            errors: usageResult.usage.errors,
            subrequests: usageResult.usage.subrequests,
            cpu_time_ms: usageResult.usage.cpu_time_ms,
            period: usageResult.usage.period,
            script: usageResult.usage.script,
          },
        }
      : {
          available: false,
          cached: usageResult.cached,
          error: usageResult.error,
          hint: hasCfCreds
            ? "Analytics API call failed — check token permissions (Account Analytics Read)."
            : "Configure CF_ACCOUNT_ID + CF_API_TOKEN secrets.",
        },
    notes,
    cron_last,
    ...(hint ? { hint } : {}),
  };
}

function esc(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function renderHtml(p: StatusPayload): string {
  const u = p.usage_24h.data;
  const usageBlock = u
    ? `<table>
        <tr><th>Requests (24h)</th><td>${u.requests.toLocaleString()}</td></tr>
        <tr><th>Errors</th><td>${u.errors.toLocaleString()}</td></tr>
        <tr><th>Subrequests</th><td>${u.subrequests.toLocaleString()}</td></tr>
        <tr><th>CPU p50</th><td>${u.cpu_time_ms.p50 ?? "—"} ms</td></tr>
        <tr><th>CPU p99</th><td>${u.cpu_time_ms.p99 ?? "—"} ms</td></tr>
        <tr><th>Script</th><td><code>${esc(u.script)}</code></td></tr>
        <tr><th>Period</th><td><small>${esc(u.period.start)} → ${esc(u.period.end)}</small></td></tr>
        ${p.usage_24h.cached ? "<tr><th>Cache</th><td>5 min</td></tr>" : ""}
      </table>`
    : `<p class="muted">${esc(p.usage_24h.hint ?? p.usage_24h.error ?? "Usage unavailable")}</p>`;

  const feat = (k: string, on: boolean) =>
    `<span class="pill ${on ? "on" : "off"}">${k}</span>`;

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta http-equiv="refresh" content="60" />
  <title>${esc(p.service)} status</title>
  <style>
    :root { font-family: system-ui, sans-serif; background: #0f1419; color: #e7ecf3; }
    body { max-width: 52rem; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; }
    h1 { font-size: 1.5rem; margin-bottom: 0.25rem; }
    .ver { color: #8b9cb3; font-size: 0.9rem; }
    table { width: 100%; border-collapse: collapse; margin: 1rem 0; }
    th, td { text-align: left; padding: 0.4rem 0.6rem; border-bottom: 1px solid #2a3544; }
    th { color: #8b9cb3; font-weight: 500; width: 40%; }
    code { background: #1a2332; padding: 0.1rem 0.35rem; border-radius: 4px; font-size: 0.85em; }
    .pill { display: inline-block; margin: 0.15rem; padding: 0.15rem 0.5rem; border-radius: 999px; font-size: 0.75rem; }
    .pill.on { background: #1e3a2f; color: #7dcea0; }
    .pill.off { background: #2a2228; color: #a08b96; }
    .muted { color: #8b9cb3; }
    ul { padding-left: 1.2rem; }
    a { color: #6eb6ff; }
  </style>
</head>
<body>
  <h1>${esc(p.service)}</h1>
  <p class="ver">v${esc(p.version)} · ${esc(p.time)}</p>
  <p>${esc(p.description)}</p>
  ${p.hint ? `<p><code>${esc(p.hint)}</code></p>` : ""}
  <h2>Features</h2>
  <p>
    ${feat("sess_*", true)}
    ${feat("mem_*", p.features.memory)}
    ${feat(`RAG (${p.features.rag_backend})`, p.features.rag)}
    ${feat("mem_encrypt", p.features.mem_encrypt)}
    ${feat("cron_reindex", p.features.cron_reindex)}
    ${feat("cron_vector_gc", p.features.cron_vector_gc)}
    ${feat("cf_api", p.features.cf_api_ready)}
    ${feat("mem_legacy", p.features.memory_legacy)}
    ${feat("multi-tenant", p.bindings.tokens_kv)}
  </p>
  <h2>Last mem cron</h2>
  ${
    p.cron_last.available
      ? `<table>
        <tr><th>At</th><td><small>${esc(p.cron_last.at ?? "")}</small></td></tr>
        <tr><th>Owners</th><td>${p.cron_last.owners ?? 0}</td></tr>
        <tr><th>Reindex upserted</th><td>${p.cron_last.reindex_upserted ?? 0}</td></tr>
        <tr><th>GC deleted</th><td>${p.cron_last.gc_deleted ?? 0}</td></tr>
        <tr><th>GC complete</th><td>${p.cron_last.gc_complete ? "yes" : "no"}</td></tr>
      </table>`
      : `<p class="muted">No cron report in KV yet.</p>`
  }
  <h2>Worker usage (24h)</h2>
  ${usageBlock}
  <h2>Routes</h2>
  <p><strong>Public:</strong> ${p.routes.public.map((r) => `<code>${esc(r)}</code>`).join(", ")}</p>
  <p><strong>Auth required:</strong></p>
  <ul>${p.routes.authenticated.map((r) => `<li><code>${esc(r)}</code></li>`).join("")}</ul>
  <h2>Notes</h2>
  <ul>${p.notes.map((n) => `<li>${esc(n)}</li>`).join("")}</ul>
  <p class="muted">JSON: <a href="/?format=json">/?format=json</a> · Health: <a href="/health">/health</a></p>
</body>
</html>`;
}

export async function handleStatusBoard(
  request: Request,
  env: Env,
): Promise<Response> {
  const url = new URL(request.url);
  const wantJson =
    url.searchParams.get("format") === "json" ||
    (request.headers.get("Accept") ?? "").includes("application/json");

  const payload = await buildStatusPayload(env);

  if (wantJson) {
    return jsonResponse(payload);
  }

  return new Response(renderHtml(payload), {
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Cache-Control": "public, max-age=60",
      "X-Content-Type-Options": "nosniff",
    },
  });
}
