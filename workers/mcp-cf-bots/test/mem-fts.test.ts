import { describe, expect, it, vi, type MockInstance } from "vitest";
import { escapeFtsQuery, ftsSearch } from "../src/mem-fts";

describe("escapeFtsQuery", () => {
  it("returns empty for blank input", () => {
    expect(escapeFtsQuery("")).toBe("");
    expect(escapeFtsQuery("   ")).toBe("");
  });

  it("wraps multi-word queries as quoted terms", () => {
    expect(escapeFtsQuery("hello world")).toBe('"hello" "world"');
    expect(escapeFtsQuery("  foo   bar  ")).toBe('"foo" "bar"');
  });

  it("escapes embedded double quotes", () => {
    expect(escapeFtsQuery('say "hi"')).toBe('"say" """hi"""');
    expect(escapeFtsQuery('"only"')).toBe('"""only"""');
  });
});

describe("ftsSearch", () => {
  it("returns empty without querying when match is blank", () => {
    const query = vi.fn();
    expect(ftsSearch(query, { query: "", topK: 5 })).toEqual([]);
    expect(query).not.toHaveBeenCalled();
  });

  it("passes escaped match and clamps topK to the sql query fn", () => {
    const queryFn: MockInstance<
      (sql: string, ...bindings: unknown[]) => Array<Record<string, unknown>>
    > = vi.fn((_sql: string, ..._bindings: unknown[]) => [
      { chunk_id: "c1", mem_key: "k1", score: -0.5 },
    ]);
    const query = queryFn as unknown as <T extends Record<string, unknown>>(
      sql: string,
      ...bindings: unknown[]
    ) => T[];
    const hits = ftsSearch(query, {
      query: "hello world",
      topK: 100,
      tag: 'tag"1',
      updated_after: "2026-01-01T00:00:00Z",
    });

    expect(hits).toEqual([{ chunk_id: "c1", mem_key: "k1", score: -0.5 }]);
    expect(queryFn).toHaveBeenCalledOnce();
    const [sql, match, tagLike] = queryFn.mock.calls[0]!;
    expect(sql).toContain("mem_fts MATCH");
    expect(match).toBe('"hello" "world"');
    expect(tagLike).toBe('%"tag1"%');
    expect(queryFn.mock.calls[0]!.at(-1)).toBe(60);
  });
});
