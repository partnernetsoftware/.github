#!/usr/bin/env bash
# nanolisp shell-promote — Phase 9 promote ladder bootstrap via run-bootstrap-plan.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-promote.lisp"
C_COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-promote-smoke=fail no_binary"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-rs-shell-promote-smoke=fail no_plan"; exit 1; }

plan_log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
log="$plan_log"
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-shell-promote-smoke=fail plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'hash-match.ok=1' || {
  echo "nano-jit-rs-shell-promote-smoke=fail hash_match"
  echo "$log"
  exit 1
}
for marker in \
  nanolisp-shell-promote-embed \
  nanolisp-shell-promote-ci-subset \
  nanolisp-shell-promote-com-script; do
  echo "$log" | grep -q "$marker" || {
    echo "nano-jit-rs-shell-promote-smoke=fail marker=$marker"
    echo "$log"
    exit 1
  }
done
echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
  echo "nano-jit-rs-shell-promote-smoke=fail noarg"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-script-step1' || {
  echo "nano-jit-rs-shell-promote-smoke=fail script_run"
  echo "$log"
  exit 1
}

if [ -x "$C_COM" ]; then
  if [ -z "${NANO_C_RELEASE_HAS_SHELL+x}" ]; then
    # shellcheck source=nanolisp-c-release-shell-probe.sh
    . "$ROOT/lab/nano-lisp-jit/retired/scripts/nanolisp-c-release-shell-probe.sh"
    nanolisp_c_release_shell_probe_apply >/dev/null
  fi
  log=$("$C_COM" 2>&1) || rc=$?
  rc=${rc:-0}
  if [ "${NANO_C_RELEASE_HAS_SHELL}" = 1 ]; then
    echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
      echo "nano-jit-rs-shell-promote-smoke=fail c_com_shell_mode"
      echo "$log"
      exit 1
    }
  else
    if [ "$rc" -ne 2 ]; then
      echo "nano-jit-rs-shell-promote-smoke=fail c_com_exit expected=2 actual=$rc"
      echo "$log"
      exit 1
    fi
    echo "$log" | grep -q 'usage:' || {
      echo "nano-jit-rs-shell-promote-smoke=fail c_com_usage"
      echo "$log"
      exit 1
    }
  fi
fi

steps=$(echo "$plan_log" | sed -n 's/^bootstrap-plan.steps=//p' | head -1)
echo "nano-jit-rs-shell-promote-smoke=ok steps=${steps:-13}"
