#!/usr/bin/env bash
# nanolisp product gate — build + all Rust smoke scripts + unit tests.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"
echo "nanolisp.gate=begin"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compile-parity.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-ape-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-aot-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-lisp-tu-link-smoke.sh"
(cd "$ROOT/lab/nano-jit-rs" && cargo test)
echo "nanolisp.gate=ok"
