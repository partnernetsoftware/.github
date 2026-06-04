#!/usr/bin/env bash
# C track shell no-arg smoke — source grep, host cc runner, release COM GAP (manifest pin unchanged).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RETIRED="$ROOT/lab/nano-lisp-jit/retired"
RUNNER_SRC="$RETIRED/archive-c/runner"
C_COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-c-noarg.lisp"
HOST_BIN="$ROOT/lab/nano-lisp-jit/.build/nano-lisp-jit-host-shell-noarg"
GATE="$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-c-gate.sh"
cd "$ROOT"

echo "nano-jit-c-shell-noarg-smoke=begin"

grep -q 'cmd_shell_noarg' "$RUNNER_SRC/nano_main.c" || {
  echo "nano-jit-c-shell-noarg-smoke=fail source_main"
  exit 1
}
grep -q 'cmd_shell_noarg' "$RUNNER_SRC/nano_shell_cli.c" || {
  echo "nano-jit-c-shell-noarg-smoke=fail source_shell_cli"
  exit 1
}
echo "nano-jit-c-shell-noarg-smoke=ok source_grep"

if ! command -v cc >/dev/null 2>&1; then
  echo "nano-jit-c-shell-noarg-smoke=skip host_cc_missing"
else
  mkdir -p "$(dirname "$HOST_BIN")"
  cc -DNANO_LISP_JIT \
    -I "$ROOT/lab/lispjit-ir" \
    -I "$RUNNER_SRC" \
    -Os -s "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" \
    -ldl -o "$HOST_BIN"
  chmod +x "$HOST_BIN"
  log=$("$HOST_BIN" 2>&1) || true
  echo "$log" | grep -q 'shell.mode=' || {
    echo "nano-jit-c-shell-noarg-smoke=fail host_mode"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q 'nanolisp-shell-script-step1' || {
    echo "nano-jit-c-shell-noarg-smoke=fail host_step1"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q 'ret=0' || {
    echo "nano-jit-c-shell-noarg-smoke=fail host_ret"
    echo "$log"
    exit 1
  }
  log=$("$HOST_BIN" shell 2>&1) || true
  echo "$log" | grep -q 'shell.mode=lbin-script' || {
    echo "nano-jit-c-shell-noarg-smoke=fail host_shell_cmd"
    echo "$log"
    exit 1
  }
  echo "nano-jit-c-shell-noarg-smoke=ok host_cc runner=$HOST_BIN"
fi

[ -x "$C_COM" ] || { echo "nano-jit-c-shell-noarg-smoke=fail no_c_com"; exit 1; }
log=$("$C_COM" 2>&1) || rc=$?
rc=${rc:-0}
if [ "$rc" -ne 2 ]; then
  echo "nano-jit-c-shell-noarg-smoke=fail release_exit expected=2 actual=$rc"
  echo "$log"
  exit 1
fi
echo "$log" | grep -q 'usage:' || {
  echo "nano-jit-c-shell-noarg-smoke=fail release_usage"
  echo "$log"
  exit 1
}
echo "nano-jit-c-shell-noarg-smoke=ok release_com_gap usage_exit=2"

if [ -x "$C_COM" ]; then
  rc=0
  log=$("$C_COM" run-bootstrap-plan "$PLAN" 2>&1) || rc=$?
  [ "$rc" -eq 0 ] || {
    echo "nano-jit-c-shell-noarg-smoke=fail bootstrap_plan_rc rc=$rc"
    echo "$log"
    exit 1
  }
  ok_count=$(echo "$log" | grep -c 'spawn-wait.ok=1' || true)
  [ "$ok_count" -ge 3 ] || {
    echo "nano-jit-c-shell-noarg-smoke=fail bootstrap_plan_spawn ok=$ok_count"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q 'nanolisp-shell-script-step1' || {
    echo "nano-jit-c-shell-noarg-smoke=fail bootstrap_plan_run"
    echo "$log"
    exit 1
  }
  echo "nano-jit-c-shell-noarg-smoke=ok bootstrap_plan"
fi

bash "$GATE" >/tmp/nano-jit-c-gate-shell-noarg.log 2>&1 || {
  tail -20 /tmp/nano-jit-c-gate-shell-noarg.log >&2 || true
  echo "nano-jit-c-shell-noarg-smoke=fail c_gate"
  exit 1
}
echo "nano-jit-c-shell-noarg-smoke=ok c_gate"

echo "nano-jit-c-shell-noarg-smoke=ok"
