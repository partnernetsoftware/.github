export { SessionStoreDO } from "./session-do";
export { RegistryDO } from "./registry-do";
export { MemorySqliteDO } from "./memory-do";
export { MemoryDO } from "./memory-do-legacy";

import { authenticateRequest } from "./auth";
import { handlePublicHealth, handleWhoAmI } from "./health";
import { handleStatusBoard } from "./status-board";
import { apiError } from "./http-util";
import { handleVaultRest } from "./vault-api";
import { handleMcpHttp, isMcpHttpRequest } from "./mcp-http";
import { assertBodySize } from "./validate";
import { runMemCron } from "./mem-cron";

export default {
  async scheduled(
    _controller: ScheduledController,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<void> {
    ctx.waitUntil(
      runMemCron(env).then((report) => {
        console.log(JSON.stringify({ event: "mem_cron", ...report }));
      }),
    );
  },

  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (
      (url.pathname === "/" || url.pathname === "") &&
      (request.method === "GET" || request.method === "HEAD")
    ) {
      if (request.method === "HEAD") {
        return new Response(null, {
          headers: { "Cache-Control": "public, max-age=60" },
        });
      }
      return handleStatusBoard(request, env);
    }

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
