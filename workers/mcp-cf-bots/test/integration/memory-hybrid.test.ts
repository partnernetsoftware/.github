import { env } from "cloudflare:test";
import { describe, expect, it, vi } from "vitest";
import { runHybridSearch } from "../../src/mem-hybrid-search";

const OWNER = "hybrid-integration-owner";
const QUERY_EMBED = [1, 0, 0, 0];

function memoryStub() {
  if (!env.MEMORY_STORE) {
    throw new Error("MEMORY_STORE binding missing");
  }
  const id = env.MEMORY_STORE.idFromName(OWNER);
  return env.MEMORY_STORE.get(id);
}

async function putEntry(
  stub: DurableObjectStub,
  key: string,
  content: string,
  embedding?: number[],
) {
  const res = await stub.fetch(
    `https://memory.internal/entry/${encodeURIComponent(key)}`,
    {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        chunks: [{ content, embedding }],
        tags: ["hybrid-test"],
      }),
    },
  );
  expect(res.ok).toBe(true);
  const body = (await res.json()) as { id: string };
  return body.id;
}

describe("hybrid search (DO + runHybridSearch)", () => {
  it("merges DO embed vector hits with FTS keyword hits", async () => {
    const stub = memoryStub();
    const vecKey = `hyb-vec-${Date.now()}`;
    const ftsKey = `hyb-fts-${Date.now()}`;

    const chunkId = await putEntry(
      stub,
      vecKey,
      "orbital nebula vector lane alpha",
      QUERY_EMBED,
    );
    await putEntry(stub, ftsKey, "crusty banana pastry kitchen recipe");

    const aiEnv = { AI: env.AI } as Env;
    if (env.AI) {
      vi.spyOn(env.AI, "run").mockResolvedValue({
        data: [QUERY_EMBED],
      } as Awaited<ReturnType<Ai["run"]>>);
    }

    const { matches, mode } = await runHybridSearch(aiEnv, stub, OWNER, "banana", 8);
    expect(mode).toBe("hybrid");
    expect(matches.some((m) => m.key === ftsKey)).toBe(true);

    if (env.AI) {
      const sem = await runHybridSearch(aiEnv, stub, OWNER, "nebula vector", 8);
      expect(sem.mode).toBe("hybrid");
      expect(sem.matches.some((m) => m.key === vecKey)).toBe(true);
      expect(sem.matches.some((m) => m.source === "vector")).toBe(true);
      void chunkId;
    }
  });

  it("merges mocked Vectorize hits with FTS (no live AI/Vectorize API)", async () => {
    if (!env.AI || !env.MEM_VECTORS) {
      return;
    }

    const stub = memoryStub();
    const vecKey = `hyb-vz-${Date.now()}`;
    const ftsKey = `hyb-vz-fts-${Date.now()}`;

    const putBody = (await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(vecKey)}`,
      {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          chunks: [{ content: "satellite vector catalog item" }],
          tags: ["hybrid-test"],
        }),
      },
    ).then((r) => r.json())) as { id: string; replaced_chunk_ids?: string[] };

    const chunkId = putBody.id;
    await putEntry(stub, ftsKey, "tropical mango smoothie bowl");

    vi.spyOn(env.AI, "run").mockResolvedValue({
      data: [QUERY_EMBED],
    } as Awaited<ReturnType<Ai["run"]>>);

    vi.spyOn(env.MEM_VECTORS, "query").mockResolvedValue({
      matches: [
        {
          id: `${OWNER}::${chunkId}`,
          score: 0.95,
          metadata: { owner: OWNER, key: vecKey, mem_id: chunkId },
        },
      ],
      count: 1,
    } as VectorizeMatches);

    const { matches, mode } = await runHybridSearch(env, stub, OWNER, "mango", 8);
    expect(mode).toBe("hybrid");
    expect(matches.some((m) => m.key === ftsKey)).toBe(true);
    expect(matches.some((m) => m.key === vecKey && m.source === "vector")).toBe(
      true,
    );
  });
});
