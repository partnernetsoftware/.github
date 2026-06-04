#!/usr/bin/env bash
# nanolisp build-slice genesis-pin + build-slice-compile smoke — zero host cc vs plan-compile.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
PIN_X86="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
PIN_A64="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64"
PLAN_PIN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-full-runner-genesis-pin-prove.lisp"
PLAN_COMPILE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-goal-zero-genesis-pin-compile-prove.lisp"
OUT_PIN="$ROOT/lab/nano-lisp-jit/.build/v45-fr75-genesis-pin-x86.elf"
OUT_A64="$ROOT/lab/nano-lisp-jit/.build/v45-rs-genesis-aarch64.elf"
OUT_COMPILE="$ROOT/lab/nano-lisp-jit/.build/v45-zgp76-compile-x86.elf"
A64_PLAN="$ROOT/lab/nano-lisp-jit/.build/v45-rs-genesis-a64-plan.lisp"
MIN_COMPILE_BYTES=154000
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=fail no_binary"; exit 1; }
[ -f "$PIN_X86" ] || { echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=fail no_pin_x86"; exit 1; }

run_plan() {
  local label="$1" plan="$2" flag="$3" out="$4"
  rm -f "$out"
  local log
  log=$("$RS" run-bootstrap-plan "$plan" 2>&1) || true
  echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
    echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=fail ${label}_plan"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q "$flag" || {
    echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=fail ${label}_flag"
    echo "$log"
    exit 1
  }
  local bytes
  bytes=$(wc -c <"$out" | tr -d ' ')
  [ "${bytes:-0}" -gt 0 ] || {
    echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=fail ${label}_missing_out"
    exit 1
  }
  if [ -x "$COM" ]; then
    rm -f "$out"
    local com_log
    com_log=$("$COM" run-bootstrap-plan "$plan" 2>&1) || true
    echo "$com_log" | grep -q "$flag" || {
      echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=fail ${label}_com_flag"
      echo "$com_log"
      exit 1
    }
  fi
  echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=ok ${label} bytes=$bytes"
}

unset NANO_LISPJIT_FROM_LISP NANO_REGENESIS NANO_BUILD_SLICE_SELFHOST_REUSE
rm -f "$OUT_PIN" "$OUT_COMPILE" "$OUT_A64"

run_plan genesis-pin "$PLAN_PIN" 'build-slice.role=genesis-pin' "$OUT_PIN"
pin_bytes=$(wc -c <"$PIN_X86" | tr -d ' ')
out_bytes=$(wc -c <"$OUT_PIN" | tr -d ' ')
[ "$pin_bytes" = "$out_bytes" ] || {
  echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=fail genesis_bytes pin=$pin_bytes out=$out_bytes"
  exit 1
}

run_plan plan-compile "$PLAN_COMPILE" 'build-slice.role=plan-compile' "$OUT_COMPILE"
compile_bytes=$(wc -c <"$OUT_COMPILE" | tr -d ' ')
[ "${compile_bytes:-0}" -ge "$MIN_COMPILE_BYTES" ] || {
  echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=fail compile_bytes=$compile_bytes"
  exit 1
}

cat >"$A64_PLAN" <<'EOF'
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-rs-genesis-aarch64.elf"
               "aarch64"))
EOF
run_plan genesis-aarch64 "$A64_PLAN" 'build-slice.role=genesis-pin' "$OUT_A64"
a64_bytes=$(wc -c <"$OUT_A64" | tr -d ' ')
pin_a64=$(wc -c <"$PIN_A64" | tr -d ' ')
[ "$a64_bytes" = "$pin_a64" ] || {
  echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=fail aarch64_bytes out=$a64_bytes pin=$pin_a64"
  exit 1
}

echo "nano-jit-rs-bootstrap-build-slice-genesis-smoke=ok"
