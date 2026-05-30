#!/usr/bin/env bash
# Orchestrator calls this: restore CLI auth from mcp-cf-bots Worker, then run Claude Code as worker.
# Requires MCP_CF_BOTS_URL + MCP_CF_BOTS_TOKEN (legacy SESSION_VAULT_*).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
: "${MCP_CF_BOTS_OWNER:=${SESSION_VAULT_OWNER:-}}"
if [[ -z "${MCP_CF_BOTS_OWNER}" ]]; then
  echo "claude_worker: MCP_CF_BOTS_OWNER must be set" >&2
  exit 1
fi
export MCP_CF_BOTS_OWNER
export MCP_CF_BOTS_URL="${MCP_CF_BOTS_URL:-${SESSION_VAULT_URL:-}}"
export MCP_CF_BOTS_TOKEN="${MCP_CF_BOTS_TOKEN:-${SESSION_VAULT_TOKEN:-}}"

if [[ -z "${MCP_CF_BOTS_URL:-}" || -z "${MCP_CF_BOTS_TOKEN:-}" ]]; then
  echo "claude_worker: MCP_CF_BOTS_URL and MCP_CF_BOTS_TOKEN must be set (Cloud Agent Secrets)" >&2
  exit 1
fi

python3 "$ROOT/tools/session_vault_claude_code.py" restore >/dev/null
# setup-token in vault only (optional)
if eval "$(python3 "$ROOT/tools/session_vault_claude_code.py" print-env 2>/dev/null)"; then
  :
fi

exec claude "$@"
