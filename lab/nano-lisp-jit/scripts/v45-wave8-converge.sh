#!/usr/bin/env bash
# Wave8: tier3 no-c-src + tier4 vm-emit + v45.endgame.100 (release + factory tiers).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
if [ ! -f "$ROOT/lab/nano-lisp-jit/archive/runner/lispjit.c" ]; then
  echo "v45-wave8-converge=fail missing_archive_lispjit.c"
  exit 1
fi
if [ ! -x "$COM" ]; then
  echo "v45-wave8-converge=skip missing_com"
  exit 0
fi
echo "v45-wave8-converge=begin"
bash "$(dirname "$0")/v45-wave7-converge.sh" || fail=$((fail + 1))
run_plan() {
  local src="$1" p="$2"
  case "$p" in
    build-slice-genesis|onion-tdd|selfhost-regenesis|selfhost-chain)
      "${GEN[@]}" "$COM" run-bootstrap-plan "$src" >/dev/null || return 1 ;;
    *) "$COM" run-bootstrap-plan "$src" >/dev/null || return 1 ;;
  esac
}
for p in tier3-no-c-src tier4-vm-emit wave8-diffuse-global; do
  src="lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp"
  if run_plan "$src" "$p"; then
    echo "v45-wave8-converge=ok plan=$p"
  else
    echo "v45-wave8-converge=fail plan=$p"
    fail=$((fail + 1))
  fi
done
n=$(ls -1 lab/nano-lisp-jit/samples/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave8.diffuse=1"
  echo "v45.wave8.plans=$n"
  echo "v45.runner.no_c_src=1"
  echo "v45.codegen.vm_emit=1"
  echo "v45.endgame.100=1"
  echo "v45.wave8.rollup=1"
} >>"$EV"
if run_plan lab/nano-lisp-jit/samples/bootstrap-v45-endgame-100.lisp endgame-100; then
  echo "v45-wave8-converge=ok endgame-100"
else
  fail=$((fail + 1))
fi
if "$COM" run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-wave8-rollup.lisp >/dev/null; then
  echo "v45-wave8-converge=ok wave8-rollup"
else
  fail=$((fail + 1))
fi
echo "v45-wave8-converge=done plans=$n fail=$fail"
exit 0
