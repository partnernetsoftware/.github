import { mcpServerInfo, trimOpt } from "./config";
import {
  buildHealthFeatures,
  buildProductionHints,
  customDomainHint,
} from "./health-detail";
import { jsonResponse } from "./http-util";
import type { AuthContext } from "./auth";

export async function handlePublicHealth(env: Env): Promise<Response> {
  let version = "unknown";
  try {
    version = mcpServerInfo(env).version;
  } catch {
    /* vars optional for bare health */
  }
  const { features, cron_last } = await buildHealthFeatures(env);
  const hint = customDomainHint(env);
  const production_hints = buildProductionHints(env, features);
  const apiVersion = trimOpt(env.MCP_API_VERSION) ?? "1.0";
  return jsonResponse({
    ok: true,
    service: "mcp-cf-bots",
    version,
    api_version: apiVersion,
    api_stable: true,
    features: {
      ...features,
      fts: true,
    },
    cron_last,
    ...(production_hints.length > 0 ? { production_hints } : {}),
    ...(hint ? { hint } : {}),
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
