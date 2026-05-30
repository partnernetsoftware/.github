import { mcpServerInfo } from "./config";
import { jsonResponse } from "./http-util";
import type { AuthContext } from "./auth";

export function handlePublicHealth(env: Env): Response {
  let version = "unknown";
  try {
    version = mcpServerInfo(env).version;
  } catch {
    /* vars optional for bare health */
  }
  return jsonResponse({
    ok: true,
    service: "mcp-cf-bots",
    version,
  });
}

export function handleWhoAmI(auth: AuthContext): Response {
  if (auth.role === "admin") {
    return jsonResponse({ role: "admin" });
  }
  return jsonResponse({
    role: "user",
    owner: auth.owner,
    token_id: auth.tokenId,
    label: auth.label,
  });
}
