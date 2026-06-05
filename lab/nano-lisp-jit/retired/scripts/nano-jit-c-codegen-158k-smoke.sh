#!/usr/bin/env bash
# C track 158KB pure Lisp codegen smoke — build-slice-lisp-profile + lisp-root in-plan.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
HOST_BIN="$ROOT/lab/nano-lisp-jit/.build/nano-lisp-jit-host-codegen-158k"
DAILY="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-158k-daily.lisp"
BUNDLE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-158k-bundle-daily.lisp"
cd "$ROOT"

echo "nano-jit-c-codegen-158k-smoke=begin"
[ -x "$COM" ] || { echo "nano-jit-c-codegen-158k-smoke=fail no_com"; exit 1; }

for plan in "$DAILY" "$BUNDLE"; do
  grep -q 'build-slice-lisp-profile' "$plan" || {
    echo "nano-jit-c-codegen-158k-smoke=fail no_profile plan=$plan"
    exit 1
  }
  grep -qE 'NANO_LISPJIT_FROM_LISP|\(build-slice-compile |/bin/sh' "$plan" && {
    echo "nano-jit-c-codegen-158k-smoke=fail audit_forbidden plan=$plan"
    exit 1
  }
done
echo "nano-jit-c-codegen-158k-smoke=ok audit plans"

RUNNER="$COM"
if command -v cc >/dev/null 2>&1; then
  mkdir -p "$(dirname "$HOST_BIN")"
  cc -DNANO_LISP_JIT \
    -I "$ROOT/lab/lispjit-ir" \
    -I "$ROOT/lab/nano-lisp-jit/archive/c/runner" \
    -Os -s "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" \
    -ldl -o "$HOST_BIN"
  chmod +x "$HOST_BIN"
  probe=$(mktemp)
  printf '%s\n' '(bootstrap (lisp-root "."))' >"$probe"
  if ! "$COM" run-bootstrap-plan "$probe" 2>&1 | grep -q 'lisp-root=\.'; then
    RUNNER="$HOST_BIN"
    echo "nano-jit-c-codegen-158k-smoke=ok host_cc runner=$HOST_BIN"
  fi
  rm -f "$probe"
fi

log=$("$RUNNER" run-bootstrap-plan "$DAILY" 2>&1) || {
  echo "$log"
  echo "nano-jit-c-codegen-158k-smoke=fail daily_plan"
  exit 1
}
echo "$log" | grep -q 'build-slice-lisp-profile.profile=compose-15link-semantic-unified' || {
  echo "nano-jit-c-codegen-158k-smoke=fail profile_marker"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'build-slice-lisp.compose15_full_codegen=1' || {
  echo "nano-jit-c-codegen-158k-smoke=fail full_codegen"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'link.code.bytes=154017' || {
  echo "nano-jit-c-codegen-158k-smoke=fail link_code_bytes"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-c-codegen-158k-smoke=fail exit42"
  echo "$log"
  exit 1
}
echo "nano-jit-c-codegen-158k-smoke=ok daily_plan"

flat=$(mktemp -d)
iso=$(mktemp -d)
trap 'rm -rf "$flat" "$iso"' EXIT
mkdir -p "$flat/bootstrap" "$flat/lisp/modules-semantic" "$flat/lisp/modules" "$flat/.build"
cp "$RUNNER" "$flat/nano-lisp.com"
chmod +x "$flat/nano-lisp.com"
cp "$BUNDLE" "$flat/bootstrap/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/modules-semantic/." "$flat/lisp/modules-semantic/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/modules/." "$flat/lisp/modules/"
cp "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" "$flat/lisp/lispjit.c"
flat_log=$(cd "$flat" && ./nano-lisp.com run-bootstrap-plan \
  bootstrap/bootstrap-v45-codegen-158k-bundle-daily.lisp 2>&1) || {
  echo "$flat_log"
  echo "nano-jit-c-codegen-158k-smoke=fail flat_bundle"
  exit 1
}
echo "$flat_log" | grep -q 'lisp-root=\.' || {
  echo "nano-jit-c-codegen-158k-smoke=fail flat_lisp_root"
  echo "$flat_log"
  exit 1
}
echo "$flat_log" | grep -q 'compose15_full_codegen=1' || {
  echo "nano-jit-c-codegen-158k-smoke=fail flat_codegen"
  echo "$flat_log"
  exit 1
}
echo "nano-jit-c-codegen-158k-smoke=ok flat_bundle"

mkdir -p "$iso/lab/nano-lisp-jit/release" "$iso/lab/nano-lisp-jit/lisp/bootstrap" \
  "$iso/lab/nano-lisp-jit/lisp/core" "$iso/lab/nano-lisp-jit/lisp/modules-semantic" \
  "$iso/lab/nano-lisp-jit/lisp/modules" "$iso/lab/nano-lisp-jit/archive/c/runner" \
  "$iso/lab/nano-lisp-jit/.build"
cp "$RUNNER" "$iso/lab/nano-lisp-jit/release/nano-lisp.com"
chmod +x "$iso/lab/nano-lisp-jit/release/nano-lisp.com"
cp "$DAILY" "$iso/lab/nano-lisp-jit/lisp/bootstrap/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/core/." "$iso/lab/nano-lisp-jit/lisp/core/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/modules-semantic/." "$iso/lab/nano-lisp-jit/lisp/modules-semantic/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/modules/." "$iso/lab/nano-lisp-jit/lisp/modules/"
cp "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" "$iso/lab/nano-lisp-jit/archive/c/runner/"
iso_log=$(cd "$iso" && lab/nano-lisp-jit/release/nano-lisp.com run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-158k-daily.lisp 2>&1) || {
  echo "$iso_log"
  echo "nano-jit-c-codegen-158k-smoke=fail isolated_tree"
  exit 1
}
echo "$iso_log" | grep -q 'compose15_full_codegen=1' || {
  echo "nano-jit-c-codegen-158k-smoke=fail isolated_codegen"
  echo "$iso_log"
  exit 1
}
echo "nano-jit-c-codegen-158k-smoke=ok isolated_tree"
echo "nano-jit-c-codegen-158k-smoke=ok"
