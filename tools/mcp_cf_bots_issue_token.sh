#!/usr/bin/env bash
# Deprecated — use workers/mcp-cf-bots/scripts/issue_token.sh
exec "$(cd "$(dirname "$0")/.." && pwd)/workers/mcp-cf-bots/scripts/issue_token.sh" "$@"
