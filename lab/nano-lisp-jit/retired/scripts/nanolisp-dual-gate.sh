#!/usr/bin/env bash
# Dual-track product gate — C release SSOT + Rust nanolisp SOTA.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"
echo "nanolisp.dual-gate=begin"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-c-gate.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-gate.sh"
echo "nanolisp.dual-gate=ok"
echo "nanolisp.dual-gate.progress=see lab/nano-lisp-jit/v4.5/OVERALL-PROGRESS.md"
