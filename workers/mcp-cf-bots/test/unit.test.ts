import { describe, expect, it } from "vitest";
import { safeEqual } from "../src/http-util";
import { splitMemoryContent } from "../src/mem-chunk";
import { mergeHybridResults } from "../src/mem-hybrid";
import { ragBackend, semanticRagEnabled } from "../src/mem-embed";
import {
  memCronGcPagesPerRun,
  memCronReindexEnabled,
  memCronVectorGcEnabled,
  memEncryptAtRest,
} from "../src/mem-config";
import { memoryVectorId, parseMemoryVectorId } from "../src/memory-store";
import { resolveToolName, TOOL_ALIASES } from "../src/tool-aliases";
import { toolsForAuth } from "../src/tool-defs";
import {
  maxBodyBytes,
  validateKey,
  validateOwnerId,
  assertBodySize,
  requireSiteProfile,
} from "../src/validate";

describe("safeEqual", () => {
  it("matches equal strings", () => {
    expect(safeEqual("cfb_abc", "cfb_abc")).toBe(true);
  });
  it("rejects different strings", () => {
    expect(safeEqual("a", "b")).toBe(false);
    expect(safeEqual("aa", "a")).toBe(false);
  });
});

describe("tool aliases", () => {
  it("maps legacy session_* names", () => {
    expect(resolveToolName("session_put")).toBe("sess_put");
    expect(resolveToolName("browser_session_save")).toBe("sess_save");
  });
  it("passes through current names", () => {
    expect(resolveToolName("sess_list")).toBe("sess_list");
  });
  it("covers all alias entries", () => {
    for (const [legacy, current] of Object.entries(TOOL_ALIASES)) {
      expect(resolveToolName(legacy)).toBe(current);
    }
  });
});

describe("validate", () => {
  const env = { MAX_BODY_BYTES: "1000" } as Env;

  it("validates site/profile keys", () => {
    expect(validateKey("site", "github.com")).toBe("github.com");
    expect(() => validateKey("site", "")).toThrow(/invalid site/);
    expect(() => validateKey("site", "bad space")).toThrow();
  });

  it("validates owner ids", () => {
    expect(validateOwnerId("cloud-agent")).toBe("cloud-agent");
    expect(() => validateOwnerId("")).toThrow();
  });

  it("reads max body from env", () => {
    expect(maxBodyBytes(env)).toBe(1000);
    expect(maxBodyBytes({} as Env)).toBe(2_000_000);
  });

  it("rejects oversized Content-Length", () => {
    expect(() => assertBodySize("2000", env)).toThrow(/too large/);
    expect(() => assertBodySize(null, env)).not.toThrow();
  });

  it("lists mem tools for user auth", () => {
    const tools = toolsForAuth({ role: "user", owner: "alice", tokenId: "x" });
    const names = tools.map((t) => t.name);
    expect(names).toContain("mem_put");
    expect(names).not.toContain("auth_token_create");
    for (const t of tools.filter((x) => x.name.startsWith("mem_"))) {
      expect(t.properties).not.toHaveProperty("owner");
    }
  });
});

describe("mem chunk", () => {
  it("splits long text into multiple chunks", () => {
    const text = "a".repeat(2000);
    const chunks = splitMemoryContent(text, 500);
    expect(chunks.length).toBeGreaterThan(1);
    expect(chunks[0]!.index).toBe(0);
  });

  it("keeps short text as one chunk", () => {
    expect(splitMemoryContent("hello", 1500)).toEqual([
      { index: 0, text: "hello" },
    ]);
  });
});

describe("mem hybrid", () => {
  it("merges vector and keyword hits via RRF", () => {
    const base = {
      content: "x",
      updated_at: "2026-01-01T00:00:00Z",
    };
    const merged = mergeHybridResults(
      [
        {
          id: "1",
          key: "a",
          score: 0.9,
          source: "vector",
          ...base,
        },
      ],
      [
        {
          id: "2",
          key: "b",
          score: 1,
          source: "keyword",
          ...base,
        },
      ],
      2,
    );
    expect(merged).toHaveLength(2);
    expect(merged[0]!.key).toBeTruthy();
  });
});

describe("memory", () => {
  it("builds stable vector ids", () => {
    expect(memoryVectorId("cloud-agent", "uuid-1")).toBe("cloud-agent::uuid-1");
  });

  it("parses vector ids", () => {
    expect(parseMemoryVectorId("alice::chunk-1")).toEqual({
      owner: "alice",
      chunkId: "chunk-1",
    });
    expect(parseMemoryVectorId("bad")).toBeNull();
  });

  it("reads mem cron and encrypt flags", () => {
    expect(memEncryptAtRest({ MEM_ENCRYPT: "true" } as Env)).toBe(true);
    expect(memCronReindexEnabled({ MEM_CRON_REINDEX: "1" } as Env)).toBe(true);
    expect(memCronVectorGcEnabled({} as Env)).toBe(false);
  });

  it("reads gc pages per cron run", () => {
    expect(memCronGcPagesPerRun({ MEM_CRON_GC_PAGES_PER_RUN: "10" } as Env)).toBe(10);
    expect(memCronGcPagesPerRun({} as Env)).toBe(5);
  });

  it("detects rag backends", () => {
    expect(ragBackend({} as Env)).toBe("keyword");
    expect(ragBackend({ AI: {} as Ai } as Env)).toBe("do_embed");
    expect(
      ragBackend({ AI: {} as Ai, MEM_VECTORS: {} as VectorizeIndex } as Env),
    ).toBe("vectorize");
    expect(semanticRagEnabled({ AI: {} as Ai } as Env)).toBe(true);
  });
});

describe("validate site/profile", () => {
  it("parses site/profile from args", () => {
    const { site, profile } = requireSiteProfile({
      site: "github.com",
      profile: "default",
    });
    expect(site).toBe("github.com");
    expect(profile).toBe("default");
  });
});
