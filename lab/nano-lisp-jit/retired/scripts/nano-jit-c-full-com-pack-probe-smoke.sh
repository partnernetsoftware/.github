#!/usr/bin/env bash
# B′ pack-ape probe — full x86 codegen + aarch64 lisp slice → .com (host-cc).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
HOST_BIN="$ROOT/lab/nano-lisp-jit/.build/nano-lisp-jit-host-full-pack-probe"
PROBE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-pack-probe.lisp"
cd "$ROOT"

echo "nano-jit-c-full-com-pack-probe-smoke=begin"
command -v cc >/dev/null 2>&1 || {
  echo "nano-jit-c-full-com-pack-probe-smoke=skip no_cc"
  exit 0
}
[ -f "$PROBE" ] || {
  echo "nano-jit-c-full-com-pack-probe-smoke=fail no_probe"
  exit 1
}
mkdir -p "$ROOT/lab/nano-lisp-jit/.build" "$(dirname "$HOST_BIN")"
cc -DNANO_LISP_JIT \
  -I "$ROOT/lab/lispjit-ir" \
  -I "$ROOT/lab/nano-lisp-jit/archive/c/runner" \
  -Os -s "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" \
  -ldl -o "$HOST_BIN"
chmod +x "$HOST_BIN"

log=$("$HOST_BIN" run-bootstrap-plan "$PROBE" 2>&1) || {
  echo "$log"
  echo "nano-jit-c-full-com-pack-probe-smoke=fail plan"
  exit 1
}
echo "$log" | grep -qE 'build-slice.lispjit_full_codegen=compose15_(bulk_scale|semantic_unified)' || {
  echo "nano-jit-c-full-com-pack-probe-smoke=fail x86_codegen"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=pack-ape' || {
  echo "nano-jit-c-full-com-pack-probe-smoke=fail pack_step"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=inspect-ape' || {
  echo "nano-jit-c-full-com-pack-probe-smoke=fail inspect"
  echo "$log"
  exit 1
}
bytes=$(echo "$log" | grep -E '^[0-9]+$' | tail -1)
[ -n "$bytes" ] && [ "$bytes" -gt 10000 ] || {
  echo "nano-jit-c-full-com-pack-probe-smoke=fail com_bytes bytes=$bytes"
  echo "$log"
  exit 1
}
echo "nano-jit-c-full-com-pack-probe-smoke=ok bytes=$bytes"
