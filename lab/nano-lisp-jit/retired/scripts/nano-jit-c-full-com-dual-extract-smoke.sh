#!/usr/bin/env bash
# Dual-extract probe — x86+aarch64 slices from pinned release COM → pack-ape → spawn child plan.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
PROBE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-dual-extract-probe.lisp"
CHILD="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-regenesis-child.lisp"
cd "$ROOT"

audit_plan() {
  local plan="$1"
  local name="$2"
  local bad=0
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    if grep -qE "$pat" "$plan"; then
      echo "nano-jit-c-full-com-dual-extract-smoke=fail audit pattern=$pat plan=$name"
      bad=1
    fi
  done <<'PATS'
retired/scripts/.*\.sh
build_nano_jit\.sh
/bin/sh
/bin/cmp
PATS
  [ "$bad" -eq 0 ] || exit 1
  echo "nano-jit-c-full-com-dual-extract-smoke=ok audit plan=$name"
}

echo "nano-jit-c-full-com-dual-extract-smoke=begin"
[ -x "$COM" ] || {
  echo "nano-jit-c-full-com-dual-extract-smoke=skip no_com"
  exit 0
}
[ -f "$PROBE" ] || {
  echo "nano-jit-c-full-com-dual-extract-smoke=fail no_probe"
  exit 1
}
[ -f "$CHILD" ] || {
  echo "nano-jit-c-full-com-dual-extract-smoke=fail no_child"
  exit 1
}
mkdir -p "$ROOT/lab/nano-lisp-jit/.build"

audit_plan "$PROBE" dual-extract-probe
audit_plan "$CHILD" regenesis-child

log=$("$COM" run-bootstrap-plan "$PROBE" 2>&1) || {
  echo "$log"
  echo "nano-jit-c-full-com-dual-extract-smoke=fail plan"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=extract-ape-slice' || {
  echo "nano-jit-c-full-com-dual-extract-smoke=fail extract_step"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'extract-ape-slice.arch=x86_64' || {
  echo "nano-jit-c-full-com-dual-extract-smoke=fail x86_extract"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'extract-ape-slice.arch=aarch64' || {
  echo "nano-jit-c-full-com-dual-extract-smoke=fail aarch64_extract"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=pack-ape' || {
  echo "nano-jit-c-full-com-dual-extract-smoke=fail pack_step"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=inspect-ape' || {
  echo "nano-jit-c-full-com-dual-extract-smoke=fail inspect_step"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-c-full-com-dual-extract-smoke=fail child_plan"
  echo "$log"
  exit 1
}
bytes=$(echo "$log" | grep -E '^[0-9]+$' | tail -1)
[ -n "$bytes" ] && [ "$bytes" -ge 850000 ] || {
  echo "nano-jit-c-full-com-dual-extract-smoke=fail com_bytes bytes=$bytes"
  echo "$log"
  exit 1
}
echo "nano-jit-c-full-com-dual-extract-smoke=ok bytes=$bytes"
