import { describe, expect, it } from "vitest";
import { safeEqual } from "../src/http-util";
import { resolveToolName, TOOL_ALIASES } from "../src/tool-aliases";
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

  it("parses site/profile from args", () => {
    const { site, profile } = requireSiteProfile({
      site: "github.com",
      profile: "default",
    });
    expect(site).toBe("github.com");
    expect(profile).toBe("default");
  });
});
