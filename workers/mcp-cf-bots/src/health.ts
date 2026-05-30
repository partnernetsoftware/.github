import { mcpServerInfo } from "./config";
import { jsonResponse } from "./http-util";
import type { AuthContext } from "./auth";
import { ragEnabled } from "./mem-embed";

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
    features: {
      memory: Boolean(env.MEMORY_STORE),
      rag: ragEnabled(env),
    },
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
