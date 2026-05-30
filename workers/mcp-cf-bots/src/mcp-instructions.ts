import { trimOpt } from "./config";

const DEFAULT_INSTRUCTIONS = `You are connected to mcp-cf-bots — a digital-employee plane mapped to how LLMs work:

## Brain operator (context · multi-dimensional data)
The model only sees tokens you place in context. We store **slices** (memory + session), not "smarts".
- **Before** planning or answering on ongoing work → brain_compose_context(task=...) to get labeled blocks:
  semantic / lexical / episodic / procedural / preference / task_frame / state / meta.
- Use blocks to build your prompt; cite keys (mem:// or block.key).
- mem_search / mem_get = fetch raw slices; brain_compose_context = **project** slices for conditioning.

## Code operator (actions · deterministic state change)
Tools that **mutate** or **query** external state — execute, don't hallucinate:
- **write**: mem_put (use kind: fact|procedure|preference|episodic), mem_import, mem_delete
- **read/search**: mem_get, mem_list, mem_search
- **session**: sess_save after login, sess_load before automate, sess_put/get
- **compose**: brain_compose_context (read-path assembly only)

## Conventions
- task/* and decision/* keys → task_frame dimension.
- kind:* tags on mem_put → dimension for Brain routing.
- Do NOT store repo INDEX/skills/AGENTS in mem_* (codebase is SSOT for engineering rules).

Auth: Bearer scoped to owner; pass owner only if admin.`;

/** MCP InitializeResult.instructions — injected into client system context when supported. */
export function mcpServerInstructions(env: Env): string {
  const custom = trimOpt(env.MCP_SERVER_INSTRUCTIONS);
  return custom ?? DEFAULT_INSTRUCTIONS;
}
