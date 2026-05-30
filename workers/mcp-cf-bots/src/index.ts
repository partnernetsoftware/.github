export { SessionVaultDO } from "./session-vault-do";
export { RegistryDO } from "./registry-do";

import { handleVaultRest } from "./vault-api";
import { handleMcpHttp, isMcpHttpRequest } from "./mcp-http";

function jsonError(status: number, message: string): Response {
  return Response.json({ error: message }, { status });
}

function authorize(request: Request, env: Env): boolean {
  const header = request.headers.get("Authorization");
  if (!header?.startsWith("Bearer ")) {
    return false;
  }
  const token = header.slice("Bearer ".length).trim();
  return token.length > 0 && token === env.VAULT_TOKEN;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (isMcpHttpRequest(request, url, env)) {
      if (!authorize(request, env)) {
        return jsonError(401, "Unauthorized");
      }
      return handleMcpHttp(request, env, url);
    }

    if (!authorize(request, env)) {
      return jsonError(401, "Unauthorized");
    }

    try {
      return await handleVaultRest(request, env, url);
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      return jsonError(400, message);
    }
  },
};
