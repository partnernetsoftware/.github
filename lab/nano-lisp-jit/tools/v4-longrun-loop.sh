#!/usr/bin/env bash
# Wrapper → skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts loop
set -euo pipefail
ROOT="$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)"
export PATH="${HOME}/.bun/bin:${PATH}"
exec bun run "${ROOT}/skills/nano-lisp-jit-v4-longrun/nano-lisp-jit-v4-longrun.ts" loop "$@"
