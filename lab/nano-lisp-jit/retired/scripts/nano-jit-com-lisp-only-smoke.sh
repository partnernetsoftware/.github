#!/usr/bin/env bash
# com-lisp-only smoke — user path = release/nano-lisp.com + *.lisp only (no archive embed / Rust / .sh in-plan).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
DAILY="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-com-lisp-only-daily.lisp"
SHELL_ONLY="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-com-only.lisp"
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
PATS
  [ "$bad" -eq 0 ] || exit 1
  echo "nano-jit-com-lisp-only-smoke=ok audit plan=$name"
}

echo "nano-jit-com-lisp-only-smoke=begin"
[ -x "$COM" ] || { echo "nano-jit-com-lisp-only-smoke=fail no_com"; exit 1; }

audit_plan "$DAILY" com-lisp-only-daily
audit_plan "$SHELL_ONLY" shell-com-only

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
echo "nano-jit-com-lisp-only-smoke=ok daily_plan"

iso=$(mktemp -d)
trap 'rm -rf "$iso"' EXIT
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

echo "nano-jit-com-lisp-only-smoke=ok"
