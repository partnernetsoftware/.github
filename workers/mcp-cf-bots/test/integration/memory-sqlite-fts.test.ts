import { env } from "cloudflare:test";
import { describe, expect, it } from "vitest";

const OWNER = "integration-test-owner";

function memoryStub() {
  if (!env.MEMORY_STORE) {
    throw new Error("MEMORY_STORE binding missing");
  }
  const id = env.MEMORY_STORE.idFromName(OWNER);
  return env.MEMORY_STORE.get(id);
}

describe("MemorySqliteDO FTS", () => {
  it("indexes on put and finds via /search (fts mode)", async () => {
    const stub = memoryStub();
    const key = `fts-${Date.now()}`;

    const putRes = await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(key)}`,
      {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          chunks: [{ content: "nebula catalog quantum entanglement notes" }],
          tags: ["science"],
        }),
      },
    );
    expect(putRes.ok).toBe(true);

    const searchRes = await stub.fetch("https://memory.internal/search", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        query: "quantum",
        top_k: 5,
        tag: "science",
      }),
    });
    expect(searchRes.ok).toBe(true);
    const body = (await searchRes.json()) as {
      matches: Array<{ key: string; content: string }>;
      mode: string;
    };
    expect(body.mode).toBe("fts");
    expect(body.matches.some((m) => m.key === key)).toBe(true);
    expect(body.matches[0]!.content).toMatch(/quantum/i);
  });

  it("removes fts rows on delete", async () => {
    const stub = memoryStub();
    const key = `del-${Date.now()}`;

    await stub.fetch(`https://memory.internal/entry/${encodeURIComponent(key)}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        chunks: [{ content: "ephemeral banana smoothie recipe" }],
      }),
    });

    const delRes = await stub.fetch(
      `https://memory.internal/entry/${encodeURIComponent(key)}`,
      { method: "DELETE" },
    );
    expect(delRes.ok).toBe(true);

    const searchRes = await stub.fetch("https://memory.internal/search", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ query: "banana", top_k: 5 }),
    });
    const body = (await searchRes.json()) as { matches: Array<{ key: string }> };
    expect(body.matches.some((m) => m.key === key)).toBe(false);
  });
});
