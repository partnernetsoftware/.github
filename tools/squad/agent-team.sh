#!/usr/bin/env bash
# Thin wrapper — all logic in squad_cli.py `agent-team` / `run-loop`.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
exec "$ROOT/tools/squad/squad.sh" agent-team "$@"
