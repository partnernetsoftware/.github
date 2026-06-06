#!/usr/bin/env bash
# B′ regenesis probe — full x86 codegen + aarch64 lisp slice → pack-ape → spawn child (release COM runner).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
PROBE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-regenesis-probe.lisp"
CHILD="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-regenesis-child.lisp"
cd "$ROOT"

audit_plan() {
  local plan="$1"
  local name="$2"
  local bad=0
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    if grep -qE "$pat" "$plan"; then
      echo "nano-jit-c-full-com-regenesis-probe-smoke=fail audit pattern=$pat plan=$name"
      bad=1
    fi
  done <<'PATS'
retired/scripts/.*\.sh
build_nano_jit\.sh
/bin/sh
/bin/cmp
PATS
  [ "$bad" -eq 0 ] || exit 1
  echo "nano-jit-c-full-com-regenesis-probe-smoke=ok audit plan=$name"
}

echo "nano-jit-c-full-com-regenesis-probe-smoke=begin"
[ -x "$COM" ] || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=skip no_com"
  exit 0
}
[ -f "$PROBE" ] || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail no_probe"
  exit 1
}
[ -f "$CHILD" ] || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail no_child"
  exit 1
}
mkdir -p "$ROOT/lab/nano-lisp-jit/.build"

audit_plan "$PROBE" regenesis-probe
audit_plan "$CHILD" regenesis-child

log=$("$COM" run-bootstrap-plan "$PROBE" 2>&1) || {
  echo "$log"
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail plan"
  exit 1
}
echo "$log" | grep -qE 'build-slice.lispjit_full_codegen=compose15_(bulk_scale|semantic_unified)|compose15_full_codegen=1' || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail x86_codegen"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=extract-ape-slice' || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail extract_step"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=pack-ape' || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail pack_step"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'spawn-wait.ok=1' || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail spawn_wait"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=compile' || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail child_compile"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'call.0=libc:strlen' || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail child_run"
  echo "$log"
  exit 1
}
bytes=$(echo "$log" | grep -E '^[0-9]+$' | tail -1)
[ -n "$bytes" ] && [ "$bytes" -gt 10000 ] || {
  echo "nano-jit-c-full-com-regenesis-probe-smoke=fail com_bytes bytes=$bytes"
  echo "$log"
  exit 1
}
echo "nano-jit-c-full-com-regenesis-probe-smoke=ok bytes=$bytes"
