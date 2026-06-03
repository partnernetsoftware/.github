#!/usr/bin/env bash
# nanolisp run-bootstrap-plan smoke — compose-15chain plan via Rust DSL runner.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-15chain.lisp"
PREFIX="$ROOT/lab/nano-lisp-jit/.build/v45-cl15"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-bootstrap-15chain-smoke=fail no_binary"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-bootstrap-15chain-smoke=fail no_legacy_com"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-bootstrap-15chain-smoke=fail no_plan"; exit 1; }

rm -f "$PREFIX"-*.o "$PREFIX"-linked

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-bootstrap-15chain-smoke=fail rs_plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-bootstrap-15chain-smoke=fail rs_run"
  echo "$log"
  exit 1
}

rs_bytes=$(echo "$log" | sed -n 's/^link.code.bytes=//p' | tail -1)
[ -n "$rs_bytes" ] || {
  echo "nano-jit-rs-bootstrap-15chain-smoke=fail no_link_bytes"
  echo "$log"
  exit 1
}

rm -f "$PREFIX"-*.o "$PREFIX"-linked
com_log=$("$COM" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$com_log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-bootstrap-15chain-smoke=fail com_plan"
  echo "$com_log"
  exit 1
}
com_bytes=$(echo "$com_log" | sed -n 's/^link.code.bytes=//p' | tail -1)
[ "$rs_bytes" = "$com_bytes" ] || {
  echo "nano-jit-rs-bootstrap-15chain-smoke=fail code_bytes rs=$rs_bytes com=$com_bytes"
  exit 1
}

echo "nano-jit-rs-bootstrap-15chain-smoke=ok link.code.bytes=$rs_bytes steps=$(echo "$log" | sed -n 's/^bootstrap-plan.steps=//p')"
