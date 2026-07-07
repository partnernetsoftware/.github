import { describe, expect, it } from "vitest";
import { buildProductionHints, type HealthFeatures } from "../src/health-detail";

const baseFeatures: HealthFeatures = {
  memory: true,
  rag: true,
  rag_backend: "vectorize",
  mem_encrypt: true,
  cron_reindex: true,
  cron_vector_gc: true,
  cf_api_ready: true,
};

describe("buildProductionHints", () => {
  it("returns empty when production-ready", () => {
    const env = { MCP_SESSION_SECRET: "x" } as Env;
    expect(buildProductionHints(env, baseFeatures)).toEqual([]);
  });

  it("lists missing CF API and encrypt", () => {
    const env = {} as Env;
    const hints = buildProductionHints(env, {
      ...baseFeatures,
      cf_api_ready: false,
      mem_encrypt: false,
    });
    expect(hints.some((h) => h.includes("sync-cf-api"))).toBe(true);
    expect(hints.some((h) => h.includes("MEM_ENCRYPT"))).toBe(true);
    expect(hints.some((h) => h.includes("sync-mcp-session-secret"))).toBe(true);
  });
});
