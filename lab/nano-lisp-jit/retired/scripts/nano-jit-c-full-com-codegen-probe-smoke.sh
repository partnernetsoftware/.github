#!/usr/bin/env bash
# B′ probe smoke — full profile codegen via host-cc (154KB honest partial; not 863KB COM).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
HOST_BIN="$ROOT/lab/nano-lisp-jit/.build/nano-lisp-jit-host-full-com-probe"
PROBE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-codegen-probe.lisp"
cd "$ROOT"

echo "nano-jit-c-full-com-codegen-probe-smoke=begin"
command -v cc >/dev/null 2>&1 || {
  echo "nano-jit-c-full-com-codegen-probe-smoke=skip no_cc"
  exit 0
}
[ -f "$PROBE" ] || {
  echo "nano-jit-c-full-com-codegen-probe-smoke=fail no_probe"
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
  echo "nano-jit-c-full-com-codegen-probe-smoke=fail plan"
  exit 1
}
echo "$log" | grep -q 'build-slice-lisp-profile.profile=full' || {
  echo "nano-jit-c-full-com-codegen-probe-smoke=fail profile"
  echo "$log"
  exit 1
}
echo "$log" | grep -qE 'build-slice.lispjit_full_codegen=compose15_(bulk_scale|semantic_unified)' || {
  echo "nano-jit-c-full-com-codegen-probe-smoke=fail full_codegen_marker"
  echo "$log"
  exit 1
}
echo "$log" | grep -qE 'link.code.bytes=154(017|559)' || {
  echo "nano-jit-c-full-com-codegen-probe-smoke=fail link_code_bytes"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'build-slice.lispjit_full_honest=partial_154kb_not_863kb_com' || {
  echo "nano-jit-c-full-com-codegen-probe-smoke=fail honest_marker"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'compose15_full_codegen=1' || {
  echo "nano-jit-c-full-com-codegen-probe-smoke=fail compose15_full"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'compose15_hybrid=fallback_compile' && {
  echo "nano-jit-c-full-com-codegen-probe-smoke=fail hybrid"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-c-full-com-codegen-probe-smoke=fail exit42"
  echo "$log"
  exit 1
}
echo "nano-jit-c-full-com-codegen-probe-smoke=ok"
