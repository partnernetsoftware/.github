#!/usr/bin/env bash
# Dual-track product gate — C release SSOT + Rust nanolisp SOTA.
# Shell smokes (nested, not duplicated here):
#   c-track: nano-jit-c-shell-noarg-smoke.sh (via nano-jit-c-gate.sh)
#   rs-track: shell-ci, shell-repl-vm, shell-dual, shell-fgets, shell-repl-fgets (via nano-jit-rs-gate.sh)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"
echo "nanolisp.dual-gate=begin"
echo "nanolisp.dual-gate.shell=c-track begin smokes=nano-jit-c-shell-noarg-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-c-gate.sh"
echo "nanolisp.dual-gate.shell=c-track ok"
echo "nanolisp.dual-gate.shell=rs-track begin smokes=shell-ci,shell-repl-vm,shell-dual,shell-fgets,shell-repl-fgets"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-gate.sh"
echo "nanolisp.dual-gate.shell=rs-track ok"
echo "nanolisp.dual-gate=ok"
echo "nanolisp.dual-gate.progress=see lab/nano-lisp-jit/v4.5/OVERALL-PROGRESS.md"
