#!/usr/bin/env bash
# Deprecated — use workers/mcp-cf-bots/scripts/claude_worker.sh
exec "$(cd "$(dirname "$0")/.." && pwd)/workers/mcp-cf-bots/scripts/claude_worker.sh" "$@"
