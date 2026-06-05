#!/usr/bin/env bash
# C track 158KB pure Lisp codegen smoke — build-slice-lisp-profile in-plan (no env).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
DAILY="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-158k-daily.lisp"
cd "$ROOT"

echo "nano-jit-c-codegen-158k-smoke=begin"
[ -x "$COM" ] || { echo "nano-jit-c-codegen-158k-smoke=fail no_com"; exit 1; }

grep -q 'build-slice-lisp-profile' "$DAILY" || {
  echo "nano-jit-c-codegen-158k-smoke=fail no_profile_step"
  exit 1
}
grep -qE 'NANO_LISPJIT_FROM_LISP|\(build-slice-compile |/bin/sh' "$DAILY" && {
  echo "nano-jit-c-codegen-158k-smoke=fail audit_forbidden_in_plan"
  exit 1
}
echo "nano-jit-c-codegen-158k-smoke=ok audit plan=codegen-158k-daily"

log=$("$COM" run-bootstrap-plan "$DAILY" 2>&1) || {
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
echo "nano-jit-c-codegen-158k-smoke=ok daily_plan release_com"

iso=$(mktemp -d)
trap 'rm -rf "$iso"' EXIT
mkdir -p "$iso/lab/nano-lisp-jit/release" "$iso/lab/nano-lisp-jit/lisp/bootstrap" \
  "$iso/lab/nano-lisp-jit/lisp/core" "$iso/lab/nano-lisp-jit/lisp/modules-semantic" \
  "$iso/lab/nano-lisp-jit/lisp/modules" "$iso/lab/nano-lisp-jit/archive/c/runner" \
  "$iso/lab/nano-lisp-jit/.build"
cp "$COM" "$iso/lab/nano-lisp-jit/release/nano-lisp.com"
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
