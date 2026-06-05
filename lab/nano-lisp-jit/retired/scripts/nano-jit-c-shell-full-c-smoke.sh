#!/usr/bin/env bash
# C track shell-full-c smoke — C COM run-bootstrap-plan on shell-full-c subset plan.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RELEASE_COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
HOST_BIN="$ROOT/lab/nano-lisp-jit/.build/nano-lisp-jit-host-shell-full-c"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-full-c.lisp"
cd "$ROOT"

echo "nano-jit-c-shell-full-c-smoke=begin"

[ -x "$RELEASE_COM" ] || { echo "nano-jit-c-shell-full-c-smoke=fail no_c_com"; exit 1; }
[ -f "$PLAN" ] || { echo "nano-jit-c-shell-full-c-smoke=fail no_plan"; exit 1; }

C_COM="$RELEASE_COM"
if command -v cc >/dev/null 2>&1; then
  mkdir -p "$(dirname "$HOST_BIN")"
  cc -DNANO_LISP_JIT \
    -I "$ROOT/lab/lispjit-ir" \
    -I "$ROOT/lab/nano-lisp-jit/archive/c/runner" \
    -Os -s "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" \
    -ldl -o "$HOST_BIN"
  chmod +x "$HOST_BIN"
  C_COM="$HOST_BIN"
fi

if [ -z "${NANO_C_RELEASE_HAS_SHELL+x}" ]; then
  # shellcheck source=nanolisp-c-release-shell-probe.sh
  . "$ROOT/lab/nano-lisp-jit/retired/scripts/nanolisp-c-release-shell-probe.sh"
  nanolisp_c_release_shell_probe_apply >/dev/null
fi

rc=0
log=$("$C_COM" run-bootstrap-plan "$PLAN" 2>&1) || rc=$?
[ "$rc" -eq 0 ] || {
  echo "nano-jit-c-shell-full-c-smoke=fail bootstrap_plan_rc rc=$rc"
  echo "$log"
  exit 1
}
ok_count=$(echo "$log" | grep -c 'spawn-wait.ok=1' || true)
[ "$ok_count" -ge 10 ] || {
  echo "nano-jit-c-shell-full-c-smoke=fail plan_spawn ok=$ok_count"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-full-c-ok' || {
  echo "nano-jit-c-shell-full-c-smoke=fail marker"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-v0-system' || {
  echo "nano-jit-c-shell-full-c-smoke=fail v0_output"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'nanolisp-shell-script-step1' || {
  echo "nano-jit-c-shell-full-c-smoke=fail script_run"
  echo "$log"
  exit 1
}

steps=$(echo "$log" | sed -n 's/^bootstrap-plan.steps=//p' | head -1)
echo "nano-jit-c-shell-full-c-smoke=ok steps=${steps:-?}"
