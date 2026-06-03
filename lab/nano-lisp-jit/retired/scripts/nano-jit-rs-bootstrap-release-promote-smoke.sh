#!/usr/bin/env bash
# nanolisp run-bootstrap-plan smoke — Rust release promote plan (pack-ape + inspect + run).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nanolisp-rs-release-promote.lisp"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-bootstrap-release-promote-smoke=fail no_binary"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-bootstrap-release-promote-smoke=fail no_plan"; exit 1; }

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-bootstrap-release-promote-smoke=fail plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'inspect-ape.ok=1' || {
  echo "nano-jit-rs-bootstrap-release-promote-smoke=fail inspect"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-ape-expect-exit.ok=1' || {
  echo "nano-jit-rs-bootstrap-release-promote-smoke=fail run"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-bootstrap-release-promote-smoke=ok steps=$(echo "$log" | sed -n 's/^bootstrap-plan.steps=//p')"
