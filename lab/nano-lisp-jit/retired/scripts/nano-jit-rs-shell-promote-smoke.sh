#!/usr/bin/env bash
# nanolisp shell-promote — Phase 9 promote ladder bootstrap via run-bootstrap-plan.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-promote.lisp"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-promote-smoke=fail no_binary"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-shell-promote-smoke=fail no_plan"; exit 1; }

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-shell-promote-smoke=fail plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'hash-match.ok=1' || {
  echo "nano-jit-rs-shell-promote-smoke=fail hash_match"
  echo "$log"
  exit 1
}
for marker in \
  nanolisp-shell-promote-embed \
  nanolisp-shell-promote-ci-subset \
  nanolisp-shell-promote-com-script; do
  echo "$log" | grep -q "$marker" || {
    echo "nano-jit-rs-shell-promote-smoke=fail marker=$marker"
    echo "$log"
    exit 1
  }
done
echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
  echo "nano-jit-rs-shell-promote-smoke=fail noarg"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-script-step1' || {
  echo "nano-jit-rs-shell-promote-smoke=fail script_run"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'spawn-wait.expected=2' || {
  echo "nano-jit-rs-shell-promote-smoke=fail c_noarg_expected"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'usage:' || {
  echo "nano-jit-rs-shell-promote-smoke=fail c_noarg_usage"
  echo "$log"
  exit 1
}
steps=$(echo "$log" | sed -n 's/^bootstrap-plan.steps=//p' | head -1)
echo "nano-jit-rs-shell-promote-smoke=ok steps=${steps:-12}"
