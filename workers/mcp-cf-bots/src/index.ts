export { SessionStoreDO } from "./session-do";
export { RegistryDO } from "./registry-do";

import { authenticateRequest } from "./auth";
import { handleVaultRest } from "./vault-api";
import { handleMcpHttp, isMcpHttpRequest } from "./mcp-http";

function jsonError(status: number, message: string): Response {
  return Response.json({ error: message }, { status });
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const auth = await authenticateRequest(request, env);
    if (!auth) {
      return jsonError(401, "Unauthorized");
    }

    if (isMcpHttpRequest(request, url, env)) {
      return handleMcpHttp(request, env, url, auth);
    }

    try {
      return await handleVaultRest(request, env, url, auth);
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      const status = message.includes("forbidden") ? 403 : 400;
      return jsonError(status, message);
    }
  },
};
