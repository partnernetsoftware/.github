#!/usr/bin/env bash
# nanolisp build-slice-lisp smoke — factory lisp-only regenesis plan (x86 min + aarch64 ir-exit).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-factory-build-lisp-only-regenesis.lisp"
PREFIX="$ROOT/lab/nano-lisp-jit/.build/v45-w105"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-bootstrap-build-slice-lisp-smoke=fail no_binary"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-bootstrap-build-slice-lisp-smoke=fail no_plan"; exit 1; }

rm -f "${PREFIX}"-lo-ir-aarch64.elf "${PREFIX}"-lo-min-x86.elf "${PREFIX}"-factory-lo.com

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-bootstrap-build-slice-lisp-smoke=fail plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'build-slice-lisp.mode=compile-elf64-code' || {
  echo "nano-jit-rs-bootstrap-build-slice-lisp-smoke=fail x86_mode"
  echo "$log"
  exit 1
}
echo "$log" | grep -qE 'build-slice-lisp.mode=aarch64-(vm-aot-emit|exit-emit)' || {
  echo "nano-jit-rs-bootstrap-build-slice-lisp-smoke=fail aarch64_mode"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-bootstrap-build-slice-lisp-smoke=fail run_min"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'inspect-ape.ok=1' || {
  echo "nano-jit-rs-bootstrap-build-slice-lisp-smoke=fail inspect"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-bootstrap-build-slice-lisp-smoke=ok steps=$(echo "$log" | sed -n 's/^bootstrap-plan.steps=//p')"
