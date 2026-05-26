#!/usr/bin/env bash
# Wave2 single convergence: com-verify + next.com smoke + evidence keys.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
touch "$EV"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
echo "v45-wave2-converge=begin"
bash lab/nano-lisp-jit/scripts/v45-com-verify.sh
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
for p in selfhost-modules-full factory-matrix wave2-diffuse-global selfhost-next-com-verify wave2-assess-tick wave2-rollup; do
  src="lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp"
  test -f "$src"
  "$COM" run-bootstrap-plan "$src" >/dev/null
  echo "v45-wave2-converge=ok plan=$p"
done
NEXT=lab/nano-lisp-jit/.build/v45-selfhost-next.com
SMOKE=lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-smoke.lisp
if [ -x "$NEXT" ] && [ -f "$SMOKE" ]; then
  "${GEN[@]}" "$NEXT" run-bootstrap-plan "$SMOKE" >/dev/null
  echo "v45-wave2-converge=ok next_com_smoke"
  echo "v45.selfhost.next_com=1" >> "$EV"
else
  echo "v45-wave2-converge=skip next_com missing"
fi
{
  echo "v45.wave2.diffuse=1"
  echo "v45.wave2.factory_matrix=1"
  echo "v45.selfhost.modules_full=1"
  echo "v45.wave2.rollup=1"
} >> "$EV"
echo "v45-wave2-converge=done"
