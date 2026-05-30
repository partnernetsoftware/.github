export { SessionStoreDO } from "./session-do";
export { RegistryDO } from "./registry-do";

import { authenticateRequest } from "./auth";
import { handlePublicHealth, handleWhoAmI } from "./health";
import { apiError } from "./http-util";
import { handleVaultRest } from "./vault-api";
import { handleMcpHttp, isMcpHttpRequest } from "./mcp-http";
import { assertBodySize } from "./validate";

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/health" && request.method === "GET") {
      return handlePublicHealth(env);
    }

    if (request.method !== "GET" && request.method !== "HEAD") {
      try {
        assertBodySize(request.headers.get("Content-Length"), env);
      } catch (e) {
        const message = e instanceof Error ? e.message : String(e);
        const status = message.includes("too large") ? 413 : 400;
        return apiError(status, message);
      }
    }

    if (url.pathname === "/v1/me" && request.method === "GET") {
      const auth = await authenticateRequest(request, env);
      if (!auth) {
        return apiError(401, "Unauthorized");
      }
      return handleWhoAmI(auth);
    }

    const auth = await authenticateRequest(request, env);
    if (!auth) {
      return apiError(401, "Unauthorized");
    }

    if (isMcpHttpRequest(request, url, env)) {
      return handleMcpHttp(request, env, url, auth);
    }

    try {
      return await handleVaultRest(request, env, url, auth);
    } catch (e) {
      const message = e instanceof Error ? e.message : String(e);
      const status = message.includes("forbidden")
        ? 403
        : message.includes("too large")
          ? 413
          : 400;
      return apiError(status, message);
    }
  },
};
