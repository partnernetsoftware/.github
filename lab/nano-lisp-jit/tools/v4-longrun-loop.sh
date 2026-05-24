#!/usr/bin/env bash
# v4-longrun-loop.sh — /loop 长驱直到 /goal 或超时
#
# Usage:
#   bash tools/v4-longrun-loop.sh                    # 1 batch from pointer
#   V4_LONGRUN_BATCHES=3 bash tools/v4-longrun-loop.sh
#   V4_LONGRUN_TIMEOUT_SEC=7200 V4_LONGRUN_GOAL=wave92 bash tools/v4-longrun-loop.sh
#
# Env:
#   V4_LONGRUN_BATCHES     batches per invocation (default 1)
#   V4_LONGRUN_TIMEOUT_SEC wall clock (default 5400)
#   V4_LONGRUN_GOAL        stop when next_wave > N (e.g. wave92) or "terminal" (manual)
#   V4_LONGRUN_CC          cc helper (default ~/.local/bin/cc-huoshan1-ds4pro)
#   V4_LONGRUN_PARALLEL_CC max concurrent cc jobs (default 1; wave batch is sequential)
#   NANO_SLICE_COMPILER    default native

set -euo pipefail

LAB="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$LAB/.." && pwd)"
TOOLS="$LAB/tools"
CC="${V4_LONGRUN_CC:-$HOME/.local/bin/cc-huoshan1-ds4pro}"
BATCHES="${V4_LONGRUN_BATCHES:-1}"
TIMEOUT="${V4_LONGRUN_TIMEOUT_SEC:-5400}"
GOAL="${V4_LONGRUN_GOAL:-}"
export NANO_SLICE_COMPILER="${NANO_SLICE_COMPILER:-native}"

log() { printf '[v4-loop %s] %s\n' "$(date -u +%H:%M:%S)" "$*"; }

read_ptr() { python3 "$TOOLS/v4-read-pointer.py" "$1"; }

goal_met() {
  local nw="$1"
  [[ -z "$GOAL" ]] && return 1
  if [[ "$GOAL" == terminal* ]]; then
    grep -q "100%" "$LAB/v4/PROGRESS.md" 2>/dev/null && return 0
    return 1
  fi
  if [[ "$GOAL" =~ ^wave([0-9]+)$ ]]; then
  local target="${BASH_REMATCH[1]}"
    (( nw > target )) && return 0
  fi
  return 1
}

run_cc_batch() {
  local lo="$1" hi="$2"
  local task="$TOOLS/cc-task-wave${lo}-${hi}.txt"
  if [[ ! -f "$task" ]]; then
    log "gen cc task $lo-$hi"
    python3 "$TOOLS/v4-gen-cc-task.py" "$lo" "$hi" "$task"
  fi
  if [[ ! -x "$CC" ]] && ! command -v "$CC" >/dev/null 2>&1; then
    log "ERROR: cc helper missing: $CC"
    return 2
  fi
  log "cc batch wave${lo}-${hi} (stdin task)"
  "$CC" -p --dangerously-skip-permissions \
    --add-dir "$LAB" --add-dir "$ROOT/lispjit-ir" \
    < "$task" 2>&1 | tee "/tmp/cc-wave${lo}-${hi}.log"
  grep -q 'CC_DONE tests.pass=' "/tmp/cc-wave${lo}-${hi}.log"
}

run_gate() {
  log "build + run.sh"
  bash "$LAB/build_nano_jit.sh"
  bash "$LAB/run.sh"
}

START=$(date +%s)
batch=0
while (( batch < BATCHES )); do
  now=$(date +%s)
  (( now - START >= TIMEOUT )) && { log "TIMEOUT ${TIMEOUT}s"; exit 124; }

  lo=$(read_ptr next_wave)
  hi=$(read_ptr batch_hi)
  goal_met "$lo" && { log "GOAL met at wave pointer $lo"; exit 0; }

  log "batch $((batch + 1))/$BATCHES waves $lo-$hi"
  run_cc_batch "$lo" "$hi" || { log "cc FAILED"; exit 1; }
  run_gate || { log "gate FAILED"; exit 1; }

  tp=$(grep -E '^tests\.pass=' "$LAB/.build/results.txt" | tail -1 | cut -d= -f2)
  log "gate OK tests.pass=${tp:-?}"
  batch=$((batch + 1))
  # pointer update is cc's job in LONG-RUN-TODO; composer commits after loop
done

log "LOOP_OK batches=$batch"
