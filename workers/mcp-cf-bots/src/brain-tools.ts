import type { AuthContext } from "./auth";
import { ownerForTool } from "./owner-scope";
import { checkMemRateLimit } from "./rate-limit";
import { brainComposeContext } from "./brain-compose";
import type { ContextDimensionId } from "./context-model";
import { CONTEXT_DIMENSIONS } from "./context-model";

/** MCP Brain operator tools (context compose — read path for LLM conditioning). */
export async function brainToolCall(
  env: Env,
  name: string,
  args: Record<string, unknown>,
  auth: AuthContext,
  requestOwner: string,
): Promise<string> {
  const owner = ownerForTool(auth, env, args, requestOwner);

  if (name === "brain_compose_context") {
    await checkMemRateLimit(env, owner, "mem_search");
    const task = String(args.task ?? "").trim();
    const topK = Number(args.top_k) || 8;
    let dimensions: ContextDimensionId[] | undefined;
    if (Array.isArray(args.dimensions)) {
      const raw = args.dimensions.map(String);
      const invalid = raw.filter(
        (d) => !CONTEXT_DIMENSIONS.includes(d as ContextDimensionId),
      );
      if (invalid.length > 0) {
        throw new Error(`invalid dimensions: ${invalid.join(", ")}`);
      }
      dimensions = raw as ContextDimensionId[];
    }
    let session: { site: string; profile: string } | undefined;
    if (args.session_site && args.session_profile) {
      session = {
        site: String(args.session_site),
        profile: String(args.session_profile),
      };
    }
    const result = await brainComposeContext(env, owner, {
      task,
      top_k: topK,
      dimensions,
      tag: typeof args.tag === "string" ? args.tag : undefined,
      session,
    });
    return JSON.stringify(result, null, 2);
  }

  throw new Error(`Unknown brain tool: ${name}`);
}
