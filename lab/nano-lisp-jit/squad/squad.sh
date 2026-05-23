#!/usr/bin/env bash
# v3.5 squad CLI wrapper
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
exec python3 "$ROOT/squad/squad_cli.py" "$@"
