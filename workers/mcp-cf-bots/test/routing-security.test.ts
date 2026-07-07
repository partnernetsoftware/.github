import { describe, expect, it } from "vitest";
import { handleAdminRest } from "../src/admin-api";
import { handleMemRest } from "../src/mem-rest";
import { readOptionalJsonBody } from "../src/http-util";

const env = { MEMORY_STORE: {} } as Env;
const adminAuth = { role: "admin" as const };

describe("admin mem cron routing", () => {
  it("handleMemRest ignores /v1/admin/mem/cron", async () => {
    const url = new URL("https://x/v1/admin/mem/cron");
    const req = new Request(url.toString(), { method: "POST" });
    const res = await handleMemRest(req, env, url, adminAuth);
    expect(res).toBeNull();
  });

  it("handleAdminRest serves POST /v1/admin/mem/cron", async () => {
    const url = new URL("https://x/v1/admin/mem/cron");
    const req = new Request(url.toString(), { method: "POST" });
    const res = await handleAdminRest(req, env, url, adminAuth);
    expect(res).not.toBeNull();
    expect(res!.status).not.toBe(404);
  });
});

describe("legacy migrate removed", () => {
  it("handleMemRest returns 410 for /v1/mem/migrate-legacy", async () => {
    const url = new URL("https://x/v1/mem/migrate-legacy");
    const req = new Request(url.toString(), { method: "POST" });
    const res = await handleMemRest(req, env, url, adminAuth);
    expect(res).not.toBeNull();
    expect(res!.status).toBe(410);
  });
});

describe("readOptionalJsonBody", () => {
  it("returns empty object for blank body", async () => {
    const req = new Request("https://x/", { method: "POST", body: "" });
    await expect(readOptionalJsonBody(req)).resolves.toEqual({});
  });
});
