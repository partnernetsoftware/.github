#!/usr/bin/env bash
# nanolisp shell dual-track smoke — C nano-lisp.com + Rust nanolisp shell parity.
# C no-arg expectation: default pre-promote (usage: / exit 2 via plan step). After C release
# rebake ships embedded shell, set NANO_C_RELEASE_HAS_SHELL=1 to expect shell.mode= on $C_COM.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
C_COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
R_COM="$ROOT/lab/nano-lisp-jit/release/nanolisp.com"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-dual.lisp"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-shell-dual-smoke=fail no_rs"; exit 1; }
[ -x "$C_COM" ] || { echo "nano-jit-shell-dual-smoke=fail no_c_com"; exit 1; }
[ -x "$R_COM" ] || { echo "nano-jit-shell-dual-smoke=fail no_r_com"; exit 1; }

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-shell-dual-smoke=fail plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-v0-system' || {
  echo "nano-jit-shell-dual-smoke=fail v0_output"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'resolve.*libc:stdin' || {
  echo "nano-jit-shell-dual-smoke=fail stdin"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'expect.*ok expected=nonnull' || {
  echo "nano-jit-shell-dual-smoke=fail stdin_expect"
  echo "$log"
  exit 1
}

log=$("$R_COM" 2>&1) || true
echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
  echo "nano-jit-shell-dual-smoke=fail r_com_noarg"
  echo "$log"
  exit 1
}

log=$("$C_COM" 2>&1) || rc=$?
rc=${rc:-0}
if [ "${NANO_C_RELEASE_HAS_SHELL:-0}" = 1 ]; then
  echo "$log" | grep -q 'shell.mode=' || {
    echo "nano-jit-shell-dual-smoke=fail c_com_shell_mode"
    echo "$log"
    exit 1
  }
else
  if [ "$rc" -ne 2 ]; then
    echo "nano-jit-shell-dual-smoke=fail c_com_exit expected=2 actual=$rc"
    echo "$log"
    exit 1
  fi
  echo "$log" | grep -q 'usage:' || {
    echo "nano-jit-shell-dual-smoke=fail c_com_usage"
    echo "$log"
    exit 1
  }
fi

echo "nano-jit-shell-dual-smoke=ok"
