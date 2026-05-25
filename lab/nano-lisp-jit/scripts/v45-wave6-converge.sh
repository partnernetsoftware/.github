#!/usr/bin/env bash
# Wave6: wave5 + w3 minimal probe + onion-primary + factory slim anchors.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT="$ROOT/lab/nano-lisp-jit/.build/v45-selfhost-next.com"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
if [ ! -x "$COM" ]; then
  echo "v45-wave6-converge=skip missing_com"
  exit 0
fi
echo "v45-wave6-converge=begin"
bash "$(dirname "$0")/v45-wave5-converge.sh" || fail=$((fail + 1))
run_plan() {
  "$COM" run-bootstrap-plan "$1" >/dev/null || return 1
}
if [ ! -x "$ROOT/lab/nano-lisp-jit/.build/v45-w3-lisp-only.com" ]; then
  "$COM" run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-wave3-lisp-only-regenesis.lisp >/dev/null 2>&1 || true
fi
for p in wave6-w3-minimal-probe wave6-onion-primary wave6-factory-slim wave6-diffuse-global wave6-rollup; do
  src="lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp"
  if run_plan "$src"; then
    echo "v45-wave6-converge=ok plan=$p"
  else
    echo "v45-wave6-converge=fail plan=$p"
    fail=$((fail + 1))
  fi
done
w3_ok=0
if run_plan lab/nano-lisp-jit/samples/bootstrap-v45-wave6-w3-minimal-probe.lisp; then
  w3_ok=1
  echo "v45-wave6-converge=ok w3_minimal_probe=1"
fi
if [ -x "$NEXT" ]; then
  if "${GEN[@]}" "$NEXT" run-bootstrap-plan \
      lab/nano-lisp-jit/samples/bootstrap-v45-onion-lisp-only.lisp >/dev/null 2>&1; then
    echo "v45-wave6-converge=ok next_com_onion_lisp_only=1"
    echo "v45.selfhost.next_onion_lisp_only=1" >>"$EV"
  fi
fi
n=$(ls -1 lab/nano-lisp-jit/samples/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave6.diffuse=1"
  echo "v45.wave6.plans=$n"
  echo "v45.onion.primary_lisp_only=1"
  echo "v45.w3_com.minimal_probe=$w3_ok"
  echo "v45.factory.slim=1"
  echo "v45.wave6.rollup=1"
} >>"$EV"
echo "v45-wave6-converge=done plans=$n fail=$fail w3_probe=$w3_ok"
exit 0
