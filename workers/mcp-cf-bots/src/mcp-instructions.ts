import { trimOpt } from "./config";

const DEFAULT_INSTRUCTIONS = `You are connected to mcp-cf-bots v1 (tenant session vault + memory RAG on Cloudflare).

## Use tools proactively
- User facts, preferences, project decisions → mem_put (stable keys, tags; optional kind: fact|procedure|preference|episodic).
- Before recalling prior work in this tenant → mem_search (prefer over mem_list), then mem_get.
- After browser login → sess_save; before automating a logged-in site → sess_load.
- Known memory key → resources/read mem://<key>.

## Do not
- Store repo engineering rules (INDEX, skills, AGENTS.md) in mem_* — codebase is SSOT.
- Assume SSE streaming: this server uses POST JSON-RPC for /mcp only.

Auth: Bearer is scoped to your owner; do not pass owner unless admin.`;

export function mcpServerInstructions(env: Env): string {
  const custom = trimOpt(env.MCP_SERVER_INSTRUCTIONS);
  return custom ?? DEFAULT_INSTRUCTIONS;
}
