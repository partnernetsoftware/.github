#!/usr/bin/env bash
# nanolisp run-bootstrap-plan smoke — boundary negative (compile-expect-exit 2).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-boundary-negative.lisp"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-bootstrap-boundary-negative-smoke=fail no_binary"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-bootstrap-boundary-negative-smoke=fail no_plan"; exit 1; }

rm -f "$ROOT/lab/nano-lisp-jit/.build/v45-boundary-bad-"*.lbin \
      "$ROOT/lab/nano-lisp-jit/.build/v45-boundary-bad-"*.elf

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-bootstrap-boundary-negative-smoke=fail rs_plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -c 'bootstrap-compile-expect-exit.ok=2' | grep -q '^4$' || {
  echo "nano-jit-rs-bootstrap-boundary-negative-smoke=fail expect_count"
  echo "$log"
  exit 1
}

if [ -x "$COM" ]; then
  rm -f "$ROOT/lab/nano-lisp-jit/.build/v45-boundary-bad-"*.lbin \
        "$ROOT/lab/nano-lisp-jit/.build/v45-boundary-bad-"*.elf
  com_log=$("$COM" run-bootstrap-plan "$PLAN" 2>&1) || true
  echo "$com_log" | grep -c 'bootstrap-compile-expect-exit.ok=2' | grep -q '^4$' || {
    echo "nano-jit-rs-bootstrap-boundary-negative-smoke=fail com_plan"
    echo "$com_log"
    exit 1
  }
fi

echo "nano-jit-rs-bootstrap-boundary-negative-smoke=ok"
