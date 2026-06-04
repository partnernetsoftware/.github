#!/usr/bin/env bash
# nanolisp shell-ci — Phase 4 unified shell ladder via bootstrap plan only.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-ci.lisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-ci-smoke=fail no_binary"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-shell-ci-smoke=fail no_plan"; exit 1; }

log=$("$RS" shell-ci 2>&1) || true
echo "$log" | grep -q 'shell-ci.plan=' || {
  echo "nano-jit-rs-shell-ci-smoke=fail cmd"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-shell-ci-smoke=fail plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'hash-match.ok=1' || {
  echo "nano-jit-rs-shell-ci-smoke=fail hash_match"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-ape-expect-exit.ok=1' || {
  echo "nano-jit-rs-shell-ci-smoke=fail ape"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-script-step1' || {
  echo "nano-jit-rs-shell-ci-smoke=fail script_run"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
  echo "nano-jit-rs-shell-ci-smoke=fail noarg"
  echo "$log"
  exit 1
}

if [ -x "$COM" ]; then
  log=$("$COM" spawn-wait 0 "/bin/true" 2>&1) || true
  echo "$log" | grep -q 'spawn-wait.ok=1' || {
    echo "nano-jit-rs-shell-ci-smoke=fail com_spawn"
    echo "$log"
    exit 1
  }
fi

steps=$(echo "$log" | sed -n 's/^bootstrap-plan.steps=//p' | head -1)
echo "nano-jit-rs-shell-ci-smoke=ok steps=${steps:-15}"
