#!/usr/bin/env bash
# Wave22: 工厂层 S4/S5 plan 零 lispjit.c + 进度复核.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave22-factory-lisp-only-converge=skip missing_com"
  exit 0
fi
echo "v45-wave22-factory-lisp-only-converge=begin"
bash "$(dirname "$0")/v45-cleanup-reflect.sh" || fail=$((fail + 1))

for p in selfhost-regenesis-lisp-only selfhost-chain-lisp-only mindmap-factory-lisp-only; do
  if "${GEN[@]}" "$COM" run-bootstrap-plan \
      "lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp" >/dev/null 2>&1; then
    echo "v45-wave22=ok plan=$p"
  else
    echo "v45-wave22=fail plan=$p"
    fail=$((fail + 1))
  fi
done

bash "$(dirname "$0")/v45-evidence-canonical.sh"
if [ "$fail" = 0 ]; then
  {
    echo "v45.wave22.diffuse=1"
    echo "v45.wave22.rollup=1"
    echo "v45.selfhost.plan_no_c=1"
    echo "v45.factory.selfhost_lisp_only=1"
  } >>"$EV"
  echo "v45-wave22-factory-lisp-only-converge=done fail=0"
  exit 0
fi
echo "v45-wave22-factory-lisp-only-converge=done fail=$fail"
exit 1
