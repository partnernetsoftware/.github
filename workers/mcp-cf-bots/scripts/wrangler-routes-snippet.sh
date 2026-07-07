#!/usr/bin/env bash
# Emit wrangler routes TOML for custom domain (from env, not committed).
set -euo pipefail
HOST="${1:-}"
if [[ -z "$HOST" ]]; then
  exit 0
fi
HOST="${HOST#https://}"
HOST="${HOST#http://}"
HOST="${HOST%%/*}"
cat <<TOML
[[routes]]
pattern = "$HOST"
custom_domain = true
TOML
