import { describe, expect, it } from "vitest";
import { mcpServerInstructions } from "../src/mcp-instructions";
import { handleMcpJsonRpc } from "../src/mcp-server";

const baseEnv = {
  MCP_SERVER_NAME: "mcp-cf-bots",
  MCP_SERVER_VERSION: "1.0.1",
  MCP_SERVER_DESCRIPTION: "test",
  MCP_PROTOCOL_VERSION: "2024-11-05",
  MCP_HTTP_PATH: "/mcp",
  DEFAULT_SESSION_SOURCE: "browser-use",
  VAULT_TOKEN: "test",
} as Env;

describe("mcp instructions", () => {
  it("returns default proactive-use guide", () => {
    const text = mcpServerInstructions(baseEnv);
    expect(text).toMatch(/mem_put/i);
    expect(text).toMatch(/mem_search/i);
    expect(text).toMatch(/sess_save/i);
    expect(text).toMatch(/Store repo engineering/i);
    expect(text).toMatch(/POST JSON-RPC/i);
  });

  it("initialize result includes instructions", async () => {
    const res = await handleMcpJsonRpc(
      { jsonrpc: "2.0", id: 1, method: "initialize", params: {} },
      {
        env: baseEnv,
        auth: { role: "user", owner: "alice", tokenId: "t1", label: "test" },
        requestOwner: "alice",
        sessionId: null,
        isInitialize: true,
      },
    );
    const body = res.body as { result?: { instructions?: string } };
    expect(body.result?.instructions).toContain("mem_search");
  });
});
