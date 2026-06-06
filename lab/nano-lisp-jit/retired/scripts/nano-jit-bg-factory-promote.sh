#!/usr/bin/env bash
# Background pipeline: cosmocc → factory build → release promote → c-gate.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
LOG_DIR="$ROOT/lab/nano-lisp-jit/.build/bg"
mkdir -p "$LOG_DIR"
cd "$ROOT"

exec > >(tee -a "$LOG_DIR/factory-promote.log") 2>&1
echo "nano-jit-bg-factory-promote=begin ts=$(date -Iseconds)"

bash "$ROOT/lab/nano-lisp-jit/retired/scripts/bootstrap-cosmocc.sh"
export NANO_SLICE_COMPILER=cosmo
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh"
echo "nano-jit-bg-factory-promote=ok factory_build"

bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-release-promote.sh"
echo "nano-jit-bg-factory-promote=ok release_promote"
echo "nano-jit-bg-factory-promote=done" >"$LOG_DIR/factory-promote.status"
