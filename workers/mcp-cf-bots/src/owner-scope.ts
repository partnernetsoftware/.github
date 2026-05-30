import { effectiveOwner, type AuthContext } from "./auth";

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
