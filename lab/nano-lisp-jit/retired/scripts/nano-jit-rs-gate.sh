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
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-aarch64-aot-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-lisp-tu-link-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compose5-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compose-link-smoke.sh" 8
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compose-link-smoke.sh" 15
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compose-semantic-8k-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compose-semantic-smoke.sh" 32
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compose-semantic-smoke.sh" 64
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compose-semantic-smoke.sh" 154
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compose-semantic-unified-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-compose-bulk-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-bootstrap-15chain-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-bootstrap-release-promote-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-bootstrap-proc-io-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-bootstrap-boundary-negative-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-nano-cc-build-slice-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-bootstrap-build-slice-lisp-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-bootstrap-build-slice-genesis-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-bootstrap-compose15-build-slice-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-bootstrap-compose15-hybrid-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-bootstrap-compose15-semantic-build-slice-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-release-pack-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-release-promote-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-release-slim-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-ci-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-repl-vm-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-shell-dual-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-shell-fgets-smoke.sh"
bash "$ROOT/lab/nano-lisp-jit/retired/scripts/nano-jit-rs-capsule-smoke.sh"
(cd "$ROOT/lab/nano-jit-rs" && cargo test)
echo "nanolisp.gate=ok"
