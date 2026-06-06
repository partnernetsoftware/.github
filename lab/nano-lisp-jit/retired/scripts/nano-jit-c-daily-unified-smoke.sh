#!/usr/bin/env bash
# Unified daily smoke — A (com+lisp dogfood) + B (158KB codegen) in one plan.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
REGENESIS_COM="$ROOT/lab/nano-lisp-jit/.build/v45-unified-regenesis.com"
HOST_BIN="$ROOT/lab/nano-lisp-jit/.build/nano-lisp-jit-host-daily-unified"
UNIFIED="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-daily-unified.lisp"
BUNDLE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-daily-unified-bundle.lisp"
SHELL_ONLY="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-com-only.lisp"
SHELL_BUNDLE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-com-only-bundle.lisp"
cd "$ROOT"

audit_plan() {
  local plan="$1"
  local name="$2"
  local bad=0
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    if grep -qE "$pat" "$plan"; then
      echo "nano-jit-c-daily-unified-smoke=fail audit pattern=$pat plan=$name"
      bad=1
    fi
  done <<'PATS'
retired/scripts/.*\.sh
build_nano_jit\.sh
/bin/sh
/bin/cmp
NANO_LISPJIT_FROM_LISP
\(build-slice-compile 
PATS
  [ "$bad" -eq 0 ] || exit 1
  echo "nano-jit-c-daily-unified-smoke=ok audit plan=$name"
}

echo "nano-jit-c-daily-unified-smoke=begin"
[ -x "$COM" ] || { echo "nano-jit-c-daily-unified-smoke=fail no_com"; exit 1; }
mkdir -p "$ROOT/lab/nano-lisp-jit/.build"

audit_plan "$UNIFIED" daily-unified
audit_plan "$BUNDLE" daily-unified-bundle

RUNNER="$COM"
if command -v cc >/dev/null 2>&1; then
  mkdir -p "$(dirname "$HOST_BIN")"
  cc -DNANO_LISP_JIT \
    -I "$ROOT/lab/lispjit-ir" \
    -I "$ROOT/lab/nano-lisp-jit/archive/c/runner" \
    -Os -s "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" \
    -ldl -o "$HOST_BIN"
  chmod +x "$HOST_BIN"
fi

log=$("$COM" run-bootstrap-plan "$UNIFIED" 2>&1) || {
  echo "$log"
  echo "nano-jit-c-daily-unified-smoke=fail repo_tree"
  exit 1
}
echo "$log" | grep -q 'libc:fgets' || {
  echo "nano-jit-c-daily-unified-smoke=fail repo_fgets"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=run-stdin' || {
  echo "nano-jit-c-daily-unified-smoke=fail repo_run_stdin"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'build-slice-lisp.compose15_full_codegen=1' || {
  echo "nano-jit-c-daily-unified-smoke=fail repo_codegen"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-c-daily-unified-smoke=fail repo_exit42"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=pack-ape' || {
  echo "nano-jit-c-daily-unified-smoke=fail repo_pack_ape"
  echo "$log"
  exit 1
}
regen_bytes=0
[ -f "$REGENESIS_COM" ] && regen_bytes=$(stat -c%s "$REGENESIS_COM")
[ "$regen_bytes" -gt 10000 ] || {
  echo "nano-jit-c-daily-unified-smoke=fail repo_regenesis_bytes bytes=$regen_bytes"
  echo "$log"
  exit 1
}
echo "nano-jit-c-daily-unified-smoke=ok repo_tree regenesis_bytes=$regen_bytes"

flat=$(mktemp -d)
trap 'rm -rf "$flat"' EXIT
mkdir -p "$flat/bootstrap" "$flat/lisp/shell" "$flat/lisp/core" \
  "$flat/lisp/modules-semantic" "$flat/lisp/modules" "$flat/.build"
cp "$COM" "$flat/nano-lisp.com"
chmod +x "$flat/nano-lisp.com"
cp "$BUNDLE" "$flat/bootstrap/"
cp "$SHELL_BUNDLE" "$flat/bootstrap/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/shell/." "$flat/lisp/shell/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/core/." "$flat/lisp/core/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/modules-semantic/." "$flat/lisp/modules-semantic/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/modules/." "$flat/lisp/modules/"
cp "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" "$flat/lisp/lispjit.c"

run_flat_bundle() {
  (cd "$flat" && ./nano-lisp.com run-bootstrap-plan \
    bootstrap/bootstrap-v45-daily-unified-bundle.lisp 2>&1)
}

flat_log=$(run_flat_bundle) || {
  echo "$flat_log"
  echo "nano-jit-c-daily-unified-smoke=fail flat_bundle"
  exit 1
}
BUNDLE_RUNNER="$COM"
if ! echo "$flat_log" | grep -q 'profile_upgrade=compose-15link-semantic-unified'; then
  if [ -x "$HOST_BIN" ]; then
    cp "$HOST_BIN" "$flat/nano-lisp.com"
    chmod +x "$flat/nano-lisp.com"
    BUNDLE_RUNNER="$HOST_BIN"
    flat_log=$(run_flat_bundle) || {
      echo "$flat_log"
      echo "nano-jit-c-daily-unified-smoke=fail flat_bundle_host_cc"
      exit 1
    }
  else
    echo "nano-jit-c-daily-unified-smoke=fail flat_profile_upgrade"
    echo "$flat_log"
    exit 1
  fi
fi
echo "$flat_log" | grep -q 'lisp-root=\.' || {
  echo "nano-jit-c-daily-unified-smoke=fail flat_lisp_root"
  echo "$flat_log"
  exit 1
}
echo "$flat_log" | grep -q 'libc:fgets' || {
  echo "nano-jit-c-daily-unified-smoke=fail flat_fgets"
  echo "$flat_log"
  exit 1
}
echo "$flat_log" | grep -q 'compose15_full_codegen=1' || {
  echo "nano-jit-c-daily-unified-smoke=fail flat_codegen"
  echo "$flat_log"
  exit 1
}
echo "$flat_log" | grep -q 'bootstrap-step.*=pack-ape' || {
  echo "nano-jit-c-daily-unified-smoke=fail flat_pack_ape"
  echo "$flat_log"
  exit 1
}
flat_regen_bytes=0
[ -f "$flat/.build/v45-unified-bundle-regenesis.com" ] && \
  flat_regen_bytes=$(stat -c%s "$flat/.build/v45-unified-bundle-regenesis.com")
[ "$flat_regen_bytes" -gt 10000 ] || {
  echo "nano-jit-c-daily-unified-smoke=fail flat_regenesis_bytes bytes=$flat_regen_bytes"
  echo "$flat_log"
  exit 1
}
echo "nano-jit-c-daily-unified-smoke=ok flat_bundle runner=$BUNDLE_RUNNER regenesis_bytes=$flat_regen_bytes"
echo "nano-jit-c-daily-unified-smoke=ok"
