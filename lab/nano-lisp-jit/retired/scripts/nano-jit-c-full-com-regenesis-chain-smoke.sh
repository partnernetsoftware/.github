#!/usr/bin/env bash
# B′ chain smoke — regenesis.com → extract → repack → child plan (release COM runner).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
CHAIN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-regenesis-chain-probe.lisp"
cd "$ROOT"

echo "nano-jit-c-full-com-regenesis-chain-smoke=begin"
[ -x "$COM" ] || { echo "nano-jit-c-full-com-regenesis-chain-smoke=fail no_com"; exit 1; }
[ -f "$CHAIN" ] || { echo "nano-jit-c-full-com-regenesis-chain-smoke=fail no_plan"; exit 1; }
mkdir -p "$ROOT/lab/nano-lisp-jit/.build"

log=$("$COM" run-bootstrap-plan "$CHAIN" 2>&1) || {
  echo "$log"
  echo "nano-jit-c-full-com-regenesis-chain-smoke=fail plan"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=extract-ape-slice' || {
  echo "nano-jit-c-full-com-regenesis-chain-smoke=fail extract"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-c-full-com-regenesis-chain-smoke=fail child"
  echo "$log"
  exit 1
}
bytes=$(echo "$log" | grep -E '^[0-9]+$' | tail -1)
[ -n "$bytes" ] && [ "$bytes" -gt 400000 ] || {
  echo "nano-jit-c-full-com-regenesis-chain-smoke=fail bytes=$bytes"
  echo "$log"
  exit 1
}
echo "nano-jit-c-full-com-regenesis-chain-smoke=ok bytes=$bytes"
