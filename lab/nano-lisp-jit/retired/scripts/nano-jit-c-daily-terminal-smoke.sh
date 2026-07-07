#!/usr/bin/env bash
# TERMINAL smoke — one plan: dogfood + 158k + pure-lisp pack + 871KB regenesis + child spawn.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
TERMINAL="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-daily-terminal.lisp"
BUNDLE="$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-daily-terminal-bundle.lisp"
REGEN="$ROOT/lab/nano-lisp-jit/.build/v45-terminal-regenesis.com"
PURE="$ROOT/lab/nano-lisp-jit/.build/v45-terminal-pure-lisp.com"
cd "$ROOT"

audit() {
  local plan="$1" name="$2"
  grep -qE 'retired/scripts/|build_nano_jit\.sh|/bin/sh' "$plan" && {
    echo "nano-jit-c-daily-terminal-smoke=fail audit plan=$name"; exit 1; }
  echo "nano-jit-c-daily-terminal-smoke=ok audit plan=$name"
}

echo "nano-jit-c-daily-terminal-smoke=begin"
[ -x "$COM" ] || { echo "nano-jit-c-daily-terminal-smoke=fail no_com"; exit 1; }
mkdir -p "$ROOT/lab/nano-lisp-jit/.build"
audit "$TERMINAL" terminal
audit "$BUNDLE" terminal-bundle

log=$("$COM" run-bootstrap-plan "$TERMINAL" 2>&1) || { echo "$log"; echo "nano-jit-c-daily-terminal-smoke=fail terminal"; exit 1; }
echo "$log" | grep -q 'libc:fgets' || { echo "$log"; echo "nano-jit-c-daily-terminal-smoke=fail fgets"; exit 1; }
echo "$log" | grep -q 'profile_upgrade=compose-15link-semantic-unified' || {
  echo "$log"; echo "nano-jit-c-daily-terminal-smoke=fail profile_upgrade"; exit 1; }
echo "$log" | grep -q 'compose15_full_codegen=1' || {
  echo "$log"; echo "nano-jit-c-daily-terminal-smoke=fail codegen158k"; exit 1; }
echo "$log" | grep -q 'bootstrap-step.*=pack-ape' || {
  echo "$log"; echo "nano-jit-c-daily-terminal-smoke=fail pack_ape"; exit 1; }
echo "$log" | grep -q 'spawn-wait.ok=1' || {
  echo "$log"; echo "nano-jit-c-daily-terminal-smoke=fail regenesis_child"; exit 1; }
regen_bytes=0; pure_bytes=0
[ -f "$REGEN" ] && regen_bytes=$(stat -c%s "$REGEN")
[ -f "$PURE" ] && pure_bytes=$(stat -c%s "$PURE")
[ "$regen_bytes" -gt 850000 ] || {
  echo "nano-jit-c-daily-terminal-smoke=fail regen_bytes=$regen_bytes"; echo "$log"; exit 1; }
[ "$pure_bytes" -gt 100000 ] || {
  echo "nano-jit-c-daily-terminal-smoke=fail pure_bytes=$pure_bytes"; echo "$log"; exit 1; }
echo "nano-jit-c-daily-terminal-smoke=ok terminal regenesis_bytes=$regen_bytes pure_lisp_bytes=$pure_bytes"

flat=$(mktemp -d); trap 'rm -rf "$flat"' EXIT
mkdir -p "$flat/bootstrap" "$flat/lisp/shell" "$flat/lisp/core" \
  "$flat/lisp/modules-semantic" "$flat/lisp/modules" "$flat/.build"
cp "$COM" "$flat/nano-lisp.com" && chmod +x "$flat/nano-lisp.com"
cp "$BUNDLE" "$flat/bootstrap/"
cp "$ROOT/lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-com-only-bundle.lisp" "$flat/bootstrap/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/shell/." "$flat/lisp/shell/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/core/." "$flat/lisp/core/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/modules-semantic/." "$flat/lisp/modules-semantic/"
cp -r "$ROOT/lab/nano-lisp-jit/lisp/modules/." "$flat/lisp/modules/"
cp "$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c" "$flat/lisp/lispjit.c"
flat_log=$(cd "$flat" && ./nano-lisp.com run-bootstrap-plan bootstrap/bootstrap-v45-daily-terminal-bundle.lisp 2>&1) || {
  echo "$flat_log"; echo "nano-jit-c-daily-terminal-smoke=fail bundle"; exit 1; }
bundle_regen=0
[ -f "$flat/.build/v45-terminal-bundle-regenesis.com" ] && \
  bundle_regen=$(stat -c%s "$flat/.build/v45-terminal-bundle-regenesis.com")
[ "$bundle_regen" -gt 850000 ] || {
  echo "nano-jit-c-daily-terminal-smoke=fail bundle_regen=$bundle_regen"; echo "$flat_log"; exit 1; }
echo "nano-jit-c-daily-terminal-smoke=ok bundle regenesis_bytes=$bundle_regen"
echo "nano-jit-c-daily-terminal-smoke=ok"
