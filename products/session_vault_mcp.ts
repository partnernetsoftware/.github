#!/usr/bin/env bun
/** @deprecated Use products/mcp_cf_bots_mcp.ts and MCP id mcp-cf-bots */

if (import.meta.main) {
  console.error("session_vault_mcp.ts is deprecated; use mcp_cf_bots_mcp.ts");
  const path = new URL("./mcp_cf_bots_mcp.ts", import.meta.url).pathname;
  const proc = Bun.spawn(["bun", path, ...process.argv.slice(2)], {
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
  });
  process.exit(await proc.exited);
}
