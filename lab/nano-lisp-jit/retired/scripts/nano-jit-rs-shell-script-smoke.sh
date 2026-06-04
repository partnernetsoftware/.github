#!/usr/bin/env bash
# nanolisp shell-script smoke — Phase 1 multi-command .lbin + bootstrap chain.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
SRC="$ROOT/lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
LBIN="$ROOT/lab/nano-lisp-jit/.build/v45-shell-script.lbin"
PLAN="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-script-smoke.lisp"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-shell-script-smoke=fail no_binary"; exit 1; }

rm -f "$LBIN"

log=$("$RS" compile "$SRC" "$LBIN" 2>&1) || true
echo "$log" | grep -q 'compile.engine=rust' || { echo "nano-jit-rs-shell-script-smoke=fail compile"; echo "$log"; exit 1; }

log=$("$RS" run "$LBIN" 2>&1) || true
echo "$log" | grep -q 'nanolisp-shell-script-step1' || { echo "nano-jit-rs-shell-script-smoke=fail step1"; echo "$log"; exit 1; }
echo "$log" | grep -q 'nanolisp-shell-script-step2' || { echo "nano-jit-rs-shell-script-smoke=fail step2"; echo "$log"; exit 1; }
echo "$log" | grep -q 'ret=0' || { echo "nano-jit-rs-shell-script-smoke=fail ret"; echo "$log"; exit 1; }

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || { echo "nano-jit-rs-shell-script-smoke=fail plan"; echo "$log"; exit 1; }
echo "$log" | grep -q 'read-file.ok=1' || { echo "nano-jit-rs-shell-script-smoke=fail read_file"; echo "$log"; exit 1; }
echo "$log" | grep -q 'spawn-wait.ok=1' || { echo "nano-jit-rs-shell-script-smoke=fail spawn"; echo "$log"; exit 1; }

log=$("$RS" shell 2>&1) || true
echo "$log" | grep -q 'shell.mode=lbin-script' || { echo "nano-jit-rs-shell-script-smoke=fail shell_cmd"; echo "$log"; exit 1; }
echo "$log" | grep -q 'nanolisp-shell-script-step1' || { echo "nano-jit-rs-shell-script-smoke=fail shell_run"; echo "$log"; exit 1; }

log=$("$RS" shell-repl <<'EOF'
echo nanolisp-shell-repl-echo
exit
EOF
) || true
echo "$log" | grep -q 'nanolisp-shell-repl-echo' || { echo "nano-jit-rs-shell-script-smoke=fail repl"; echo "$log"; exit 1; }
echo "$log" | grep -q 'nanolisp-shell-repl=ok' || { echo "nano-jit-rs-shell-script-smoke=fail repl_ok"; echo "$log"; exit 1; }

echo "nano-jit-rs-shell-script-smoke=ok"
