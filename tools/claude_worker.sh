#!/usr/bin/env bash
# Orchestrator calls this: restore CLI auth from session-vault, then run Claude Code as worker.
# Requires SESSION_VAULT_URL + SESSION_VAULT_TOKEN (same as session-vault MCP).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export SESSION_VAULT_OWNER="${SESSION_VAULT_OWNER:-cloud-agent}"

if [[ -z "${SESSION_VAULT_URL:-}" || -z "${SESSION_VAULT_TOKEN:-}" ]]; then
  echo "claude_worker: SESSION_VAULT_URL and SESSION_VAULT_TOKEN must be set (Cloud Agent Secrets)" >&2
  exit 1
fi

python3 "$ROOT/tools/session_vault_claude_code.py" restore >/dev/null
# setup-token in vault only (optional)
if eval "$(python3 "$ROOT/tools/session_vault_claude_code.py" print-env 2>/dev/null)"; then
  :
fi

exec claude "$@"
