/** Legacy MCP tool names (pre-0.4) → current sess_* / auth_* names. */
export const TOOL_ALIASES: Record<string, string> = {
  browser_session_save: "sess_save",
  browser_session_load: "sess_load",
  session_meta: "sess_meta",
  session_put: "sess_put",
  session_get: "sess_get",
  session_delete: "sess_delete",
  session_list: "sess_list",
};

export function resolveToolName(name: string): string {
  return TOOL_ALIASES[name] ?? name;
}
