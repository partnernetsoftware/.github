#!/usr/bin/env bash
# com-lisp-only smoke — user path = release/nano-lisp.com + *.lisp only (no archive embed / Rust / .sh / /bin/sh in-plan).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
DAILY="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-com-lisp-only-daily.lisp"
SHELL_ONLY="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-com-only.lisp"
BUNDLE_DAILY="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-com-lisp-only-bundle-daily.lisp"
BUNDLE_SHELL="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-com-only-bundle.lisp"
cd "$ROOT"

audit_plan() {
  local plan="$1"
  local name="$2"
  local bad=0
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    if grep -qE "$pat" "$plan"; then
      echo "nano-jit-com-lisp-only-smoke=fail audit pattern=$pat plan=$name"
      bad=1
    fi
  done <<'PATS'
retired/scripts/.*\.sh
build_nano_jit\.sh
lispjit\.c
archive/c/
nano-jit-rs/
/bin/sh
/bin/cmp
PATS
  [ "$bad" -eq 0 ] || exit 1
  echo "nano-jit-com-lisp-only-smoke=ok audit plan=$name"
}

cleanup() {
  rm -rf "${iso:-}" "${flat:-}"
}
trap cleanup EXIT

echo "nano-jit-com-lisp-only-smoke=begin"
[ -x "$COM" ] || { echo "nano-jit-com-lisp-only-smoke=fail no_com"; exit 1; }

audit_plan "$DAILY" com-lisp-only-daily
audit_plan "$SHELL_ONLY" shell-com-only
audit_plan "$BUNDLE_DAILY" com-lisp-only-bundle-daily
audit_plan "$BUNDLE_SHELL" shell-com-only-bundle

log=$("$COM" run-bootstrap-plan "$DAILY" 2>&1) || {
  echo "$log"
  echo "nano-jit-com-lisp-only-smoke=fail daily_plan"
  exit 1
}
echo "$log" | grep -q 'libc:fgets' || {
  echo "nano-jit-com-lisp-only-smoke=fail daily_fgets"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'bootstrap-step.*=run-stdin' || {
  echo "nano-jit-com-lisp-only-smoke=fail daily_run_stdin"
  echo "$log"
  exit 1
}
echo "nano-jit-com-lisp-only-smoke=ok daily_plan release_com"

iso=$(mktemp -d)
mkdir -p "$iso/lab/nano-lisp-jit/release" "$iso/lab/nano-lisp-jit/lisp/bootstrap" \
  "$iso/lab/nano-lisp-jit/lisp/shell" "$iso/lab/nano-lisp-jit/lisp/core" \
  "$iso/lab/nano-lisp-jit/.build"
cp "$COM" "$iso/lab/nano-lisp-jit/release/nano-lisp.com"
chmod +x "$iso/lab/nano-lisp-jit/release/nano-lisp.com"
cp "$DAILY" "$iso/lab/nano-lisp-jit/lisp/bootstrap/"
cp "$SHELL_ONLY" "$iso/lab/nano-lisp-jit/lisp/bootstrap/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/shell/." "$iso/lab/nano-lisp-jit/lisp/shell/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/core/." "$iso/lab/nano-lisp-jit/lisp/core/"
iso_log=$(cd "$iso" && lab/nano-lisp-jit/release/nano-lisp.com run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-com-lisp-only-daily.lisp 2>&1) || {
  echo "$iso_log"
  echo "nano-jit-com-lisp-only-smoke=fail isolated_tree"
  exit 1
}
echo "$iso_log" | grep -q 'shell.embed.source=rodata' || {
  echo "nano-jit-com-lisp-only-smoke=fail isolated_rodata"
  echo "$iso_log"
  exit 1
}
echo "nano-jit-com-lisp-only-smoke=ok isolated_tree"

flat=$(mktemp -d)
mkdir -p "$flat/bootstrap" "$flat/lisp/shell" "$flat/lisp/core" "$flat/.build"
cp "$COM" "$flat/nano-lisp.com"
chmod +x "$flat/nano-lisp.com"
cp "$BUNDLE_DAILY" "$flat/bootstrap/"
cp "$BUNDLE_SHELL" "$flat/bootstrap/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/shell/." "$flat/lisp/shell/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/core/." "$flat/lisp/core/"
flat_log=$(cd "$flat" && ./nano-lisp.com run-bootstrap-plan \
  bootstrap/bootstrap-v45-com-lisp-only-bundle-daily.lisp 2>&1) || {
  echo "$flat_log"
  echo "nano-jit-com-lisp-only-smoke=fail flat_bundle"
  exit 1
}
echo "$flat_log" | grep -q 'libc:fgets' || {
  echo "nano-jit-com-lisp-only-smoke=fail flat_bundle_fgets"
  echo "$flat_log"
  exit 1
}
echo "$flat_log" | grep -q 'shell.embed.source=rodata' || {
  echo "nano-jit-com-lisp-only-smoke=fail flat_bundle_rodata"
  echo "$flat_log"
  exit 1
}
echo "nano-jit-com-lisp-only-smoke=ok flat_bundle"

echo "nano-jit-com-lisp-only-smoke=ok"
