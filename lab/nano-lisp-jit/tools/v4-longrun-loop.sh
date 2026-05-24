#!/usr/bin/env bash
# v4-longrun-loop.sh — /loop 长驱：cc 下手 + gate + 指针 + commit
set -euo pipefail

LAB="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$LAB/.." && pwd)"
TOOLS="$LAB/tools"
CC="${V4_LONGRUN_CC:-$HOME/.local/bin/cc-huoshan1-ds4pro}"
BATCHES="${V4_LONGRUN_BATCHES:-3}"
TIMEOUT="${V4_LONGRUN_TIMEOUT_SEC:-7200}"
GOAL="${V4_LONGRUN_GOAL:-wave92}"
RETRIES="${V4_LONGRUN_RETRIES:-2}"
AUTO_COMMIT="${V4_LONGRUN_COMMIT:-1}"
export NANO_SLICE_COMPILER="${NANO_SLICE_COMPILER:-native}"

log() { printf '[v4-loop %s] %s\n' "$(date -u +%H:%M:%S)" "$*"; }

read_ptr() { python3 "$TOOLS/v4-read-pointer.py" "$1"; }

goal_met() {
  local nw="$1"
  [[ -z "$GOAL" ]] && return 1
  if [[ "$GOAL" == terminal* ]]; then
    grep -qE '100%|~100%' "$LAB/v4/PROGRESS.md" 2>/dev/null && return 0
    return 1
  fi
  if [[ "$GOAL" =~ ^wave([0-9]+)$ ]]; then
    local target="${BASH_REMATCH[1]}"
    (( nw > target )) && return 0
  fi
  return 1
}

run_cc_batch() {
  local lo="$1" hi="$2" attempt="$3"
  local task="$TOOLS/cc-task-wave${lo}-${hi}.txt"
  rm -f "$task"
  log "gen cc-task wave${lo}-${hi} (attempt $attempt)"
  python3 "$TOOLS/v4-gen-cc-task.py" "$lo" "$hi" "$task"
  log "cc wave${lo}-${hi}"
  "$CC" -p --dangerously-skip-permissions \
    --add-dir "$LAB" --add-dir "$ROOT/lispjit-ir" \
    < "$task" 2>&1 | tee "/tmp/cc-wave${lo}-${hi}.log"
  grep -q 'CC_DONE tests.pass=' "/tmp/cc-wave${lo}-${hi}.log"
}

run_gate() {
  bash "$LAB/build_nano_jit.sh" && bash "$LAB/run.sh"
}

try_batch() {
  local lo="$1" hi="$2"
  local a=1
  while (( a <= RETRIES )); do
    if run_cc_batch "$lo" "$hi" "$a" && run_gate; then
      return 0
    fi
    log "retry $a/$RETRIES"
    a=$((a + 1))
  done
  return 1
}

commit_batch() {
  local lo="$1" hi="$2" tp="$3"
  cd "$ROOT"
  git add lab/nano-lisp-jit lab/lispjit-ir/nano_bootstrap.c 2>/dev/null || git add lab/nano-lisp-jit
  if git diff --cached --quiet; then
    log "nothing to commit"
    return 0
  fi
  git commit -m "v4 wave${lo}-${hi}: longrun loop (tests.pass=${tp})"
  git push -u origin "$(git branch --show-current)" 2>/dev/null || true
}

START=$(date +%s)
done_batches=0
while (( done_batches < BATCHES )); do
  now=$(date +%s)
  (( now - START >= TIMEOUT )) && { log "TIMEOUT ${TIMEOUT}s"; exit 124; }

  lo=$(read_ptr next_wave)
  hi=$(( lo + 2 ))
  goal_met "$lo" && { log "GOAL $GOAL met (pointer=$lo)"; exit 0; }

  log "=== batch $((done_batches + 1))/$BATCHES waves $lo-$hi goal=$GOAL ==="
  try_batch "$lo" "$hi" || { log "FAILED wave${lo}-${hi}"; exit 1; }

  tp=$(grep -E '^tests\.pass=' "$LAB/.build/results.txt" | tail -1 | cut -d= -f2)
  python3 "$TOOLS/v4-bump-pointer.py" "$lo" "$hi" "${tp:-0}"
  (( AUTO_COMMIT )) && commit_batch "$lo" "$hi" "${tp:-?}"
  log "OK tests.pass=${tp:-?} pointer -> $((hi + 1))"
  done_batches=$((done_batches + 1))
done

log "LOOP_OK batches=$done_batches next=$(read_ptr next_wave)"
