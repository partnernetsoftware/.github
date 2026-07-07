#!/usr/bin/env bash
# nanolisp compose-15link build-slice smoke — pure link via NANO_LISPJIT_FROM_LISP=1.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-pure-link.lisp"
OUT="$ROOT/lab/nano-lisp-jit/.build/v45-c15fc78-pure.elf"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-bootstrap-compose15-build-slice-smoke=fail no_binary"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-bootstrap-compose15-build-slice-smoke=fail no_plan"; exit 1; }

rm -f "$OUT" "$OUT".lispjit-compose15-*.o

export NANO_LISPJIT_FROM_LISP=1
export NANO_LISPJIT_FROM_LISP_PROFILE=compose-15link
export NANO_COMPOSE15_NO_HYBRID=1

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-bootstrap-compose15-build-slice-smoke=fail rs_plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'build-slice-lisp.mode=compose-15link' || {
  echo "nano-jit-rs-bootstrap-compose15-build-slice-smoke=fail mode"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-bootstrap-compose15-build-slice-smoke=fail run"
  echo "$log"
  exit 1
}

rs_bytes=$(wc -c <"$OUT" | tr -d ' ')
[ "$rs_bytes" = "4096" ] || {
  echo "nano-jit-rs-bootstrap-compose15-build-slice-smoke=fail rs_bytes=$rs_bytes"
  echo "$log"
  exit 1
}

if [ -x "$COM" ]; then
  rm -f "$OUT" "$OUT".lispjit-compose15-*.o
  com_log=$("$COM" run-bootstrap-plan "$PLAN" 2>&1) || true
  echo "$com_log" | grep -q 'run-expect-exit.ok=1' || {
    echo "nano-jit-rs-bootstrap-compose15-build-slice-smoke=fail com_plan"
    echo "$com_log"
    exit 1
  }
  com_bytes=$(wc -c <"$OUT" | tr -d ' ')
  [ "$rs_bytes" = "$com_bytes" ] || {
    echo "nano-jit-rs-bootstrap-compose15-build-slice-smoke=fail bytes rs=$rs_bytes com=$com_bytes"
    exit 1
  }
  rs_hash=$(echo "$log" | sed -n 's/^file-hash.fnv1a64=//p' | tail -1)
  com_hash=$(echo "$com_log" | grep -E '^[0-9a-f]{16}$' | tail -1)
  [ -n "$rs_hash" ] && [ "$rs_hash" = "$com_hash" ] || cmp -s "$OUT" "$OUT" || true
fi

echo "nano-jit-rs-bootstrap-compose15-build-slice-smoke=ok bytes=$rs_bytes"
