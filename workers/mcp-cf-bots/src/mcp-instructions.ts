import { trimOpt } from "./config";

const DEFAULT_INSTRUCTIONS = `You are connected to mcp-cf-bots (Cloudflare): cross-agent session vault + tenant memory RAG.

## Use tools proactively (do not wait for the user to ask)

**mem_* (owner-scoped long-term memory)**
- After the user states preferences, decisions, project facts, or "remember this" → mem_put (stable key, optional tags).
- Before answering about prior work, past choices, or stored notes in this tenant → mem_search (prefer over mem_list; top_k 5–10).
- When the user returns to a multi-step project → mem_search with a short query, then mem_get on relevant keys.
- Do NOT use mem_* for repo engineering rules (INDEX, skills, AGENTS.md) — those live in the codebase.

**sess_* (browser / Playwright / CLI session reuse)**
- After logging into a site in a browser (or Playwright MCP) → sess_save (site + profile, storage_state/cookies).
- At the start of a task that needs an existing login → sess_load first, then automate.
- CLI Claude Code credentials → sess_put site=cli.claude (see tools/claude_code.py).

**resources (mem://)**
- resources/list + resources/read for a known key when the user cites a memory key.

**Admin-only** (admin Bearer): auth_token_*, mem_reindex, mem_stats, mem_vector_gc — never for normal user tasks.

Auth: your Bearer is already scoped to an owner; do not pass owner unless admin.`;

/** MCP InitializeResult.instructions — injected into client system context when supported. */
export function mcpServerInstructions(env: Env): string {
  const custom = trimOpt(env.MCP_SERVER_INSTRUCTIONS);
  return custom ?? DEFAULT_INSTRUCTIONS;
}
