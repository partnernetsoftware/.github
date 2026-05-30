import { trimOpt } from "./config";

export type WorkerUsage24h = {
  period: { start: string; end: string };
  script: string;
  requests: number;
  errors: number;
  subrequests: number;
  cpu_time_ms: { p50: number | null; p99: number | null };
  source: "cloudflare_graphql";
};

type GqlResponse = {
  data?: {
    viewer?: {
      accounts?: Array<{
        workersInvocationsAdaptive?: Array<{
          sum?: { requests?: number; errors?: number; subrequests?: number };
          quantiles?: { cpuTimeP50?: number; cpuTimeP99?: number };
        }>;
      }>;
    };
  };
  errors?: unknown[];
};

const GQL = `
query WorkerUsage($accountTag: String!, $start: Time!, $end: Time!, $script: String!) {
  viewer {
    accounts(filter: { accountTag: $accountTag }) {
      workersInvocationsAdaptive(
        limit: 10000
        filter: { scriptName: $script, datetime_geq: $start, datetime_leq: $end }
      ) {
        sum { requests errors subrequests }
        quantiles { cpuTimeP50 cpuTimeP99 }
      }
    }
  }
}
`;

function scriptName(env: Env): string {
  return trimOpt(env.MCP_SERVER_NAME) ?? "mcp-cf-bots";
}

/** Optional: needs secrets CF_ACCOUNT_ID + CF_API_TOKEN (Analytics Read). */
export async function fetchWorkerUsage24h(env: Env): Promise<WorkerUsage24h | null> {
  const accountId = trimOpt(env.CF_ACCOUNT_ID);
  const token = trimOpt(env.CF_API_TOKEN);
  if (!accountId || !token) {
    return null;
  }

  const end = new Date();
  const start = new Date(end.getTime() - 24 * 60 * 60 * 1000);
  const script = scriptName(env);

  const res = await fetch("https://api.cloudflare.com/client/v4/graphql", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      query: GQL,
      variables: {
        accountTag: accountId,
        start: start.toISOString(),
        end: end.toISOString(),
        script,
      },
    }),
  });

  if (!res.ok) {
    return null;
  }

  const json = (await res.json()) as GqlResponse;
  const rows =
    json.data?.viewer?.accounts?.[0]?.workersInvocationsAdaptive ?? [];
  if (rows.length === 0) {
    return {
      period: { start: start.toISOString(), end: end.toISOString() },
      script,
      requests: 0,
      errors: 0,
      subrequests: 0,
      cpu_time_ms: { p50: null, p99: null },
      source: "cloudflare_graphql",
    };
  }

  let requests = 0;
  let errors = 0;
  let subrequests = 0;
  let p50max = 0;
  let p99max = 0;
  for (const row of rows) {
    requests += row.sum?.requests ?? 0;
    errors += row.sum?.errors ?? 0;
    subrequests += row.sum?.subrequests ?? 0;
    if ((row.quantiles?.cpuTimeP50 ?? 0) > p50max) {
      p50max = row.quantiles!.cpuTimeP50!;
    }
    if ((row.quantiles?.cpuTimeP99 ?? 0) > p99max) {
      p99max = row.quantiles!.cpuTimeP99!;
    }
  }

  // GraphQL returns CPU time in microseconds for Workers metrics.
  const toMs = (us: number) => Math.round(us / 1000);

  return {
    period: { start: start.toISOString(), end: end.toISOString() },
    script,
    requests,
    errors,
    subrequests,
    cpu_time_ms: {
      p50: p50max ? toMs(p50max) : null,
      p99: p99max ? toMs(p99max) : null,
    },
    source: "cloudflare_graphql",
  };
}

const CACHE_KEY = "https://status.internal/analytics-v1";

export async function fetchWorkerUsageCached(env: Env): Promise<{
  usage: WorkerUsage24h | null;
  cached: boolean;
  error?: string;
}> {
  const cache = caches.default;
  const hit = await cache.match(CACHE_KEY);
  if (hit) {
    try {
      return { ...(await hit.json()), cached: true };
    } catch {
      /* refresh */
    }
  }

  try {
    const usage = await fetchWorkerUsage24h(env);
    const body = { usage, cached: false };
    if (usage) {
      await cache.put(
        CACHE_KEY,
        new Response(JSON.stringify(body), {
          headers: {
            "Content-Type": "application/json",
            "Cache-Control": "public, max-age=300",
          },
        }),
      );
    }
    return body;
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return { usage: null, cached: false, error: message };
  }
}
