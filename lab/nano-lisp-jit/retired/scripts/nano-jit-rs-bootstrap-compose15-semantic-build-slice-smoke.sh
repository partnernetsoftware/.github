#!/usr/bin/env bash
# nanolisp compose-15link semantic/expand build-slice smoke — profile module paths.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=fail no_binary"; exit 1; }

run_profile() {
  local label="$1" profile="$2" plan="$3" out="$4" expected_code="$5" flag="$6"
  rm -f "$out" "$out".lispjit-compose15-*.o
  export NANO_LISPJIT_FROM_LISP=1
  export NANO_LISPJIT_FROM_LISP_PROFILE="$profile"
  export NANO_COMPOSE15_NO_HYBRID=1
  local log
  log=$("$RS" run-bootstrap-plan "$plan" 2>&1) || true
  echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
    echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=fail ${label}_plan"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q "$flag" || {
    echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=fail ${label}_flag"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q 'build-slice-lisp.compose15_full_codegen=1' || {
    echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=fail ${label}_codegen"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q 'run-expect-exit.ok=1' || {
    echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=fail ${label}_run"
    echo "$log"
    exit 1
  }
  local rs_code
  rs_code=$(echo "$log" | sed -n 's/^link.code.bytes=//p' | tail -1)
  [ "$rs_code" = "$expected_code" ] || {
    echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=fail ${label}_code rs=$rs_code expected=$expected_code"
    echo "$log"
    exit 1
  }
  if [ -x "$COM" ]; then
    rm -f "$out" "$out".lispjit-compose15-*.o
    local com_log
    com_log=$("$COM" run-bootstrap-plan "$plan" 2>&1) || true
    echo "$com_log" | grep -q 'run-expect-exit.ok=1' || {
      echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=fail ${label}_com_plan"
      echo "$com_log"
      exit 1
    }
    local com_code
    com_code=$(echo "$com_log" | sed -n 's/^link.code.bytes=//p' | tail -1)
    [ "$rs_code" = "$com_code" ] || {
      echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=fail ${label}_parity rs=$rs_code com=$com_code"
      exit 1
    }
  fi
  echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=ok ${label} link.code.bytes=$rs_code"
}

run_profile unified compose-15link-semantic-unified \
  "$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-semantic-unified-pure-link.lisp" \
  "$ROOT/lab/nano-lisp-jit/.build/v45-c15-semantic-unified-pure.elf" \
  154017 compose15_semantic_unified=1

run_profile bulk compose-15link-bulk-scale \
  "$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-probe-compose15-bulk-scale-pure-link.lisp" \
  "$ROOT/lab/nano-lisp-jit/.build/v45-c15me82-bulk-scale-pure.elf" \
  154559 compose15_expand=1

echo "nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke=ok"
