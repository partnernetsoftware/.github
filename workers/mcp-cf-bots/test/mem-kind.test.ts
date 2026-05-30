import { describe, expect, it } from "vitest";
import { normalizeMemTags, parseMemKind } from "../src/mem-kind";

describe("mem-kind", () => {
  it("parses kind from tags", () => {
    expect(parseMemKind(["kind:note", "x"])).toBe("note");
    expect(parseMemKind(["x"])).toBeUndefined();
  });

  it("normalizes kind into tags", () => {
    expect(normalizeMemTags(["a"], "note")).toEqual(["a", "kind:note"]);
    expect(normalizeMemTags(["kind:old"], "new")).toEqual(["kind:new"]);
    expect(normalizeMemTags(undefined, undefined)).toBeUndefined();
  });
});
