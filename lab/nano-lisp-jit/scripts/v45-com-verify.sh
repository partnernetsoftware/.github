#!/usr/bin/env bash
# v4.5 com-only convergence (no full run.sh). Run from repo root.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"
COM="${COM:-lab/nano-lisp-jit/.build/nano-jit/nano-jit.com}"
if [ ! -x "$COM" ]; then
  echo "v45-com-verify=skip missing_com"
  exit 0
fi
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
plans=(
  verify-smoke verify-core v4-handoff
  boundary-i64 boundary-ptr boundary-func boundary-rodata
  boundary-probe boundary-negative boundary-feedback
  build-slice-genesis onion-tdd verify-all entry
  diffuse-global wave1-parallel-fine wave1-assess-tick wave1-rollup
)
for p in "${plans[@]}"; do
  src="lab/nano-lisp-jit/samples/bootstrap-v45-${p}.lisp"
  if [ ! -f "$src" ]; then
    echo "v45-com-verify=missing $src" >&2
    exit 1
  fi
  case "$p" in
    build-slice-genesis|onion-tdd) "${GEN[@]}" "$COM" run-bootstrap-plan "$src" >/dev/null ;;
    *) "$COM" run-bootstrap-plan "$src" >/dev/null ;;
  esac
  echo "v45-com-verify=ok plan=$p"
done
echo "v45-com-verify=done"
