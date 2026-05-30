import { describe, expect, it } from "vitest";
import {
  codeOpKind,
  inferDimension,
  normalizeMemTags,
  parseMemKind,
} from "../src/context-model";

describe("context-model", () => {
  it("maps tools to code operator kinds", () => {
    expect(codeOpKind("mem_put")).toBe("write");
    expect(codeOpKind("mem_search")).toBe("search");
    expect(codeOpKind("brain_compose_context")).toBe("compose");
    expect(codeOpKind("sess_save")).toBe("session");
  });

  it("infers dimensions from kind tags and key prefixes", () => {
    expect(inferDimension("notes", ["kind:procedure"])).toBe("procedural");
    expect(inferDimension("task/42", [])).toBe("task_frame");
    expect(inferDimension("x", [], "vector")).toBe("semantic");
  });

  it("normalizes kind into tags", () => {
    expect(normalizeMemTags(["a"], "fact")).toEqual(["a", "kind:fact"]);
    expect(parseMemKind(["kind:preference"])).toBe("preference");
  });
});
