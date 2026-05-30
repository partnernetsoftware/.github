import { trimOpt } from "./config";

/** HMAC secret for MCP-Session-Id (separate from admin VAULT_TOKEN when configured). */
export function mcpSessionHmacSecret(env: Env): string {
  const dedicated = trimOpt(env.MCP_SESSION_SECRET);
  if (dedicated) {
    return dedicated;
  }
  if (!env.VAULT_TOKEN) {
    throw new Error("VAULT_TOKEN or MCP_SESSION_SECRET must be configured");
  }
  return env.VAULT_TOKEN;
}
