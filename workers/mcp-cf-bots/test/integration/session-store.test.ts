import { env } from "cloudflare:test";
import { describe, expect, it } from "vitest";
import { sessionStub } from "../../src/session-store";

const OWNER = "sess-integration-owner";
const SITE = "example.com";
const PROFILE = "default";

describe("SessionStoreDO", () => {
  it("encrypts put and returns cookies on get", async () => {
    const stub = sessionStub(env, OWNER, SITE, PROFILE);
    const cookies = [{ name: "sid", value: "test-cookie", domain: SITE }];

    const putRes = await stub.fetch("https://session.internal/", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        cookies,
        meta: { label: "integration", source: "browser-use", updated_at: new Date().toISOString() },
      }),
    });
    expect(putRes.ok).toBe(true);

    const getRes = await stub.fetch("https://session.internal/?kind=cookies");
    expect(getRes.ok).toBe(true);
    const body = (await getRes.json()) as { cookies: typeof cookies };
    expect(body.cookies).toEqual(cookies);
  });
});
