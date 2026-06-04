#!/usr/bin/env bash
# nanolisp shell-full — Phase 8 unified bootstrap (ci + dual + embed) via run-bootstrap-plan.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-full.lisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-full-smoke=fail no_binary"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-shell-full-smoke=fail no_plan"; exit 1; }

full_log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
log="$full_log"
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-shell-full-smoke=fail plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'hash-match.ok=1' || {
  echo "nano-jit-rs-shell-full-smoke=fail hash_match"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-ape-expect-exit.ok=1' || {
  echo "nano-jit-rs-shell-full-smoke=fail ape"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-v0-system' || {
  echo "nano-jit-rs-shell-full-smoke=fail v0_output"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-script-step1' || {
  echo "nano-jit-rs-shell-full-smoke=fail script_run"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
  echo "nano-jit-rs-shell-full-smoke=fail noarg"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'resolve.*libc:stdin' || {
  echo "nano-jit-rs-shell-full-smoke=fail stdin"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'resolve.*libc:fgets' || {
  echo "nano-jit-rs-shell-full-smoke=fail fgets_resolve"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-full-repl-fgets' || {
  echo "nano-jit-rs-shell-full-smoke=fail repl_fgets"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'spawn-wait.expected=2' || {
  echo "nano-jit-rs-shell-full-smoke=fail c_noarg_expected"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'usage:' || {
  echo "nano-jit-rs-shell-full-smoke=fail c_noarg_usage"
  echo "$log"
  exit 1
}

if [ -x "$COM" ]; then
  log=$("$COM" spawn-wait 0 "/bin/true" 2>&1) || true
  echo "$log" | grep -q 'spawn-wait.ok=1' || {
    echo "nano-jit-rs-shell-full-smoke=fail com_spawn"
    echo "$log"
    exit 1
  }
fi

steps=$(echo "$full_log" | sed -n 's/^bootstrap-plan.steps=//p' | head -1)
echo "nano-jit-rs-shell-full-smoke=ok steps=${steps:-29}"
