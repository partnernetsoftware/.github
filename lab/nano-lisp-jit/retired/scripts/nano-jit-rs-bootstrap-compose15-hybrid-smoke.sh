#!/usr/bin/env bash
# nanolisp compose-15link hybrid fallback smoke — stub link → host cc lispjit.c ~158KB.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-hybrid-fallback.lisp"
OUT="$ROOT/lab/nano-lisp-jit/.build/v45-rpc77-compose15-hybrid.elf"
MIN_BYTES=154000
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-bootstrap-compose15-hybrid-smoke=fail no_binary"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-bootstrap-compose15-hybrid-smoke=fail no_plan"; exit 1; }

rm -f "$OUT" "$OUT".lispjit-compose15-*.o

export NANO_LISPJIT_FROM_LISP=1
export NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link
unset NANO_COMPOSE15_NO_HYBRID

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-bootstrap-compose15-hybrid-smoke=fail rs_plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'build-slice-lisp.compose15_hybrid=fallback_compile' || {
  echo "nano-jit-rs-bootstrap-compose15-hybrid-smoke=fail hybrid"
  echo "$log"
  exit 1
}

rs_bytes=$(wc -c <"$OUT" | tr -d ' ')
[ "${rs_bytes:-0}" -ge "$MIN_BYTES" ] || {
  echo "nano-jit-rs-bootstrap-compose15-hybrid-smoke=fail rs_bytes=$rs_bytes"
  echo "$log"
  exit 1
}

if [ -x "$COM" ]; then
  rm -f "$OUT" "$OUT".lispjit-compose15-*.o
  com_log=$("$COM" run-bootstrap-plan "$PLAN" 2>&1) || true
  echo "$com_log" | grep -q 'compose15_hybrid=fallback_compile' || {
    echo "nano-jit-rs-bootstrap-compose15-hybrid-smoke=fail com_hybrid"
    echo "$com_log"
    exit 1
  }
  com_bytes=$(wc -c <"$OUT" | tr -d ' ')
  [ "$rs_bytes" = "$com_bytes" ] || {
    echo "nano-jit-rs-bootstrap-compose15-hybrid-smoke=fail bytes rs=$rs_bytes com=$com_bytes"
    exit 1
  }
fi

echo "nano-jit-rs-bootstrap-compose15-hybrid-smoke=ok bytes=$rs_bytes"
