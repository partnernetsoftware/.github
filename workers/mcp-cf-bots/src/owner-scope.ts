import { effectiveOwner, type AuthContext } from "./auth";
import { readOwnerHeader } from "./config";

/** Resolve tenant from REST/MCP HTTP (header, query, optional tool arg). */
export function ownerFromHttpRequest(
  auth: AuthContext,
  env: Env,
  url: URL,
  request: Request,
): string {
  return effectiveOwner(auth, env, {
    headerOwner: readOwnerHeader(request, env),
    queryOwner: url.searchParams.get("owner"),
  });
}

/** Resolve tenant namespace for MCP tool calls (header + optional arg). */
export function ownerForTool(
  auth: AuthContext,
  env: Env,
  args: Record<string, unknown>,
  headerOwner: string,
): string {
  return effectiveOwner(auth, env, {
    argOwner: String(args.owner ?? "").trim() || null,
    headerOwner,
  });
}
