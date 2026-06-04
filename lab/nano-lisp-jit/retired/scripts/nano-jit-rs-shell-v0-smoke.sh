#!/usr/bin/env bash
# nanolisp shell-v0 smoke — .lbin libc:system + CLI spawn-wait/read-file + bootstrap plan.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
SRC="$ROOT/lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
LBIN="$ROOT/lab/nano-lisp-jit/.build/v45-shell-v0-system.lbin"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-v0-smoke.lisp"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-v0-smoke=fail no_binary"; exit 1; }
[ -f "$SRC" ] || { echo "nano-jit-rs-shell-v0-smoke=fail no_src"; exit 1; }

rm -f "$LBIN"

log=$("$RS" compile "$SRC" "$LBIN" 2>&1) || true
echo "$log" | grep -q 'compile.engine=rust' || {
  echo "nano-jit-rs-shell-v0-smoke=fail compile"
  echo "$log"
  exit 1
}

log=$("$RS" run "$LBIN" 2>&1) || true
echo "$log" | grep -q 'call.*libc:system result=0' || {
  echo "nano-jit-rs-shell-v0-smoke=fail run_system"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'expect.*ok expected=0' || {
  echo "nano-jit-rs-shell-v0-smoke=fail run_expect"
  echo "$log"
  exit 1
}

log=$("$RS" read-file "$ROOT/lab/nano-lisp-jit/release/manifest.txt" 2>&1) || true
echo "$log" | grep -q 'read-file.ok=1' || {
  echo "nano-jit-rs-shell-v0-smoke=fail read_file_cli"
  echo "$log"
  exit 1
}

log=$("$RS" spawn-wait 0 "/bin/true" 2>&1) || true
echo "$log" | grep -q 'spawn-wait.ok=1' || {
  echo "nano-jit-rs-shell-v0-smoke=fail spawn_wait_cli"
  echo "$log"
  exit 1
}

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-shell-v0-smoke=fail bootstrap_plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'spawn-wait.ok=1' || {
  echo "nano-jit-rs-shell-v0-smoke=fail bootstrap_spawn"
  echo "$log"
  exit 1
}

if [ -x "$COM" ]; then
  log=$("$COM" spawn-wait 0 "/bin/true" 2>&1) || true
  echo "$log" | grep -q 'spawn-wait.ok=1' || {
    echo "nano-jit-rs-shell-v0-smoke=fail com_spawn"
    echo "$log"
    exit 1
  }
fi

echo "nano-jit-rs-shell-v0-smoke=ok"
