#!/usr/bin/env bash
# Regenerable lab outputs only — does not touch samples/ or v4/ docs.
set -euo pipefail
LAB="$(cd "$(dirname "$0")/.." && pwd)"
rm -rf "$LAB/.build"/*
mkdir -p "$LAB/.build"
rm -f "$LAB/.squad/state-v4.db" "$LAB/.squad/state-v4.json" \
  "$LAB/.squad/verify.lock" "$LAB/.squad/state.json" \
  "$LAB/.squad"/state.db*
echo "cleaned: .build/* and .squad runtime (v4 + v3.5 json/db)"
