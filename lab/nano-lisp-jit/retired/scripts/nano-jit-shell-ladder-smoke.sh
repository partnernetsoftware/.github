#!/usr/bin/env bash
# Meta smoke — scoped 100% shell ladder (subset of dual-gate shell smokes, no full c/rs gate).
# Manual / CI optional: NOT wired into nanolisp-dual-gate.sh (too heavy vs daily gates).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
cd "$ROOT"

steps=()
run_step() {
  local name="$1"
  shift
  steps+=("$name")
  echo "nano-jit-shell-ladder-smoke=step begin name=$name"
  "$@"
  echo "nano-jit-shell-ladder-smoke=step ok name=$name"
}

echo "nano-jit-shell-ladder-smoke=begin"

probe_line=$("$SCRIPTS/nanolisp-c-release-shell-probe.sh")
if [ "$probe_line" != "nanolisp.c-release-shell=embedded" ]; then
  echo "nano-jit-shell-ladder-smoke=fail probe expected=embedded actual=$probe_line"
  exit 1
fi
steps+=(probe)
echo "nano-jit-shell-ladder-smoke=step ok name=probe line=$probe_line"

export NANO_SHELL_LADDER=1
export NANO_C_RELEASE_HAS_SHELL=1
run_step c-noarg bash "$SCRIPTS/nano-jit-c-shell-noarg-smoke.sh"
run_step rs-ci bash "$SCRIPTS/nano-jit-rs-shell-ci-smoke.sh"
run_step rs-full bash "$SCRIPTS/nano-jit-rs-shell-full-smoke.sh"
run_step rs-promote bash "$SCRIPTS/nano-jit-rs-shell-promote-smoke.sh"
run_step shell-dual bash "$SCRIPTS/nano-jit-shell-dual-smoke.sh"

step_list=$(IFS=,; echo "${steps[*]}")
echo "nano-jit-shell-ladder-smoke=ok steps=$step_list"
