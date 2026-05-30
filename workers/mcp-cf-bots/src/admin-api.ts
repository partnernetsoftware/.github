import {
  createUserToken,
  isAdmin,
  listUserTokens,
  revokeUserToken,
  type AuthContext,
} from "./auth";
import { apiError, jsonResponse } from "./http-util";

const TOKEN_ID_RE = /^\/v1\/admin\/tokens\/([^/]+)\/?$/;

export async function handleAdminRest(
  request: Request,
  env: Env,
  url: URL,
  auth: AuthContext,
): Promise<Response | null> {
  if (!url.pathname.startsWith("/v1/admin/")) {
    return null;
  }
  if (!isAdmin(auth)) {
    return apiError(403, "Forbidden");
  }

  if (url.pathname === "/v1/admin/tokens") {
    if (request.method === "GET") {
      const owner = url.searchParams.get("owner") ?? undefined;
      const tokens = await listUserTokens(env, owner);
      return jsonResponse({
        tokens: tokens.map((t) => ({
          id: t.id,
          owner: t.owner,
          label: t.label,
          created_at: t.created_at,
        })),
      });
    }
    if (request.method === "POST") {
      let body: { owner?: string; label?: string };
      try {
        body = (await request.json()) as { owner?: string; label?: string };
      } catch {
        return apiError(400, "Invalid JSON");
      }
      const owner = String(body.owner ?? "").trim();
      if (!owner) {
        return apiError(400, "owner is required");
      }
      const created = await createUserToken(env, owner, body.label);
      return jsonResponse({
        id: created.id,
        owner: created.owner,
        label: created.label,
        created_at: created.created_at,
        token: created.token,
        hint: "Save token now; it cannot be retrieved again.",
      });
    }
    return new Response("Method Not Allowed", { status: 405 });
  }

  const delMatch = url.pathname.match(TOKEN_ID_RE);
  if (delMatch && request.method === "DELETE") {
    const id = delMatch[1]!;
    const ok = await revokeUserToken(env, id);
    if (!ok) {
      return apiError(404, "Not found");
    }
    return jsonResponse({ ok: true });
  }

  return apiError(404, "Not found");
}

export async function adminToolCall(
  env: Env,
  name: string,
  args: Record<string, unknown>,
): Promise<string> {
  if (name === "auth_token_create") {
    const owner = String(args.owner ?? "").trim();
    if (!owner) {
      throw new Error("owner is required");
    }
    const label =
      typeof args.label === "string" ? args.label : undefined;
    const created = await createUserToken(env, owner, label);
    return JSON.stringify(
      {
        id: created.id,
        owner: created.owner,
        label: created.label,
        created_at: created.created_at,
        token: created.token,
        hint: "Give this token to the user for MCP/REST Bearer auth only.",
      },
      null,
      2,
    );
  }
  if (name === "auth_token_list") {
    const owner =
      typeof args.owner === "string" && args.owner.trim()
        ? args.owner.trim()
        : undefined;
    const tokens = await listUserTokens(env, owner);
    return JSON.stringify({ tokens }, null, 2);
  }
  if (name === "auth_token_revoke") {
    const id = String(args.token_id ?? args.id ?? "").trim();
    if (!id) {
      throw new Error("token_id is required");
    }
    const ok = await revokeUserToken(env, id);
    return JSON.stringify({ ok, revoked: ok });
  }
  throw new Error(`Unknown admin tool: ${name}`);
}
