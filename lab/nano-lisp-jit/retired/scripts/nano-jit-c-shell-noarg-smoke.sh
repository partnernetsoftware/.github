#!/usr/bin/env bash
# C track shell no-arg smoke — source grep, host cc runner, release COM GAP (manifest pin unchanged).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RETIRED="$ROOT/lab/nano-lisp-jit/retired"
RUNNER_SRC="$RETIRED/archive-c/runner"
EMBED_C="$ROOT/lab/nano-lisp-jit/archive/c/embed/shell-script.lbin"
EMBED_RS="$ROOT/lab/nano-jit-rs/embed/shell-script.lbin"
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

[ -f "$EMBED_C" ] || {
  echo "nano-jit-c-shell-noarg-smoke=fail no_c_embed path=$EMBED_C"
  exit 1
}
[ -f "$EMBED_RS" ] || {
  echo "nano-jit-c-shell-noarg-smoke=fail no_rs_embed path=$EMBED_RS"
  exit 1
}
cmp -s "$EMBED_C" "$EMBED_RS" || {
  echo "nano-jit-c-shell-noarg-smoke=fail embed_bytes_mismatch c=$EMBED_C rs=$EMBED_RS"
  exit 1
}
embed_bytes=$(wc -c <"$EMBED_C" | tr -d ' ')
echo "nano-jit-c-shell-noarg-smoke=ok embed_parity bytes=$embed_bytes"

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
  echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
    echo "nano-jit-c-shell-noarg-smoke=fail host_mode expected=embedded-lbin"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q "shell.lbin=lab/nano-lisp-jit/archive/c/embed/shell-script.lbin" || {
    echo "nano-jit-c-shell-noarg-smoke=fail host_embed_path"
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

# shellcheck source=nanolisp-c-release-shell-probe.sh
. "$ROOT/lab/nano-lisp-jit/retired/scripts/nanolisp-c-release-shell-probe.sh"
nanolisp_c_release_shell_probe_apply >/dev/null

log=$("$C_COM" 2>&1) || rc=$?
rc=${rc:-0}
if [ "${NANO_C_RELEASE_HAS_SHELL}" = 1 ]; then
  echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
    echo "nano-jit-c-shell-noarg-smoke=fail release_shell_mode expected=embedded-lbin"
    echo "$log"
    exit 1
  }
  echo "nano-jit-c-shell-noarg-smoke=ok release_has_shell=1"
else
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
  echo "nano-jit-c-shell-noarg-smoke=ok release_gap usage_exit=2"
fi

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

if [ "${NANO_C_GATE_RUNNING:-}" != 1 ]; then
  bash "$GATE" >/tmp/nano-jit-c-gate-shell-noarg.log 2>&1 || {
    tail -20 /tmp/nano-jit-c-gate-shell-noarg.log >&2 || true
    echo "nano-jit-c-shell-noarg-smoke=fail c_gate"
    exit 1
  }
  echo "nano-jit-c-shell-noarg-smoke=ok c_gate"
fi

echo "nano-jit-c-shell-noarg-smoke=ok"
