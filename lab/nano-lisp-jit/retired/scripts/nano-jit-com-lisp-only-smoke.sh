#!/usr/bin/env bash
# com-lisp-only smoke — user path = release/nano-lisp.com + *.lisp only (no archive embed / Rust / .sh / /bin/sh in-plan).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
HOST_BIN="$ROOT/lab/nano-lisp-jit/.build/nano-lisp-jit-host-com-lisp-only"
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

echo "nano-jit-com-lisp-only-smoke=begin"
[ -x "$COM" ] || { echo "nano-jit-com-lisp-only-smoke=fail no_com"; exit 1; }

audit_plan "$DAILY" com-lisp-only-daily
audit_plan "$SHELL_ONLY" shell-com-only
audit_plan "$BUNDLE_DAILY" com-lisp-only-bundle-daily
audit_plan "$BUNDLE_SHELL" shell-com-only-bundle

RUNNER="$COM"
if command -v cc >/dev/null 2>&1; then
  mkdir -p "$(dirname "$HOST_BIN")"
  cc -DNANO_LISP_JIT \
    -I "$ROOT/lab/lispjit-ir" \
    -I "$ROOT/lab/nano-lisp-jit/archive/c/runner" \
    -Os -s "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" \
    -ldl -o "$HOST_BIN"
  chmod +x "$HOST_BIN"
  RUNNER="$HOST_BIN"
  echo "nano-jit-com-lisp-only-smoke=ok host_cc runner=$HOST_BIN"
else
  echo "nano-jit-com-lisp-only-smoke=warn host_cc_missing using_release_com"
fi

cleanup() {
  rm -rf "${iso:-}" "${flat:-}" "${tmp_daily:-}"
}
trap cleanup EXIT

tmp_daily=""
if [ "$RUNNER" != "$COM" ]; then
  tmp_daily=$(mktemp)
  sed "s|lab/nano-lisp-jit/release/nano-lisp.com|$HOST_BIN|g" "$DAILY" > "$tmp_daily"
  DAILY_RUN="$tmp_daily"
else
  DAILY_RUN="$DAILY"
fi

log=$("$RUNNER" run-bootstrap-plan "$DAILY_RUN" 2>&1) || {
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
echo "nano-jit-com-lisp-only-smoke=ok daily_plan"

iso=$(mktemp -d)
mkdir -p "$iso/lab/nano-lisp-jit/release" "$iso/lab/nano-lisp-jit/lisp/bootstrap" \
  "$iso/lab/nano-lisp-jit/lisp/shell" "$iso/lab/nano-lisp-jit/lisp/core" \
  "$iso/lab/nano-lisp-jit/.build"
cp "$RUNNER" "$iso/lab/nano-lisp-jit/release/nano-lisp.com"
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
cp "$RUNNER" "$flat/nano-lisp.com"
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
