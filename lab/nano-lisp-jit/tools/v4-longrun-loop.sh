#!/usr/bin/env bash
# v4-longrun-loop.sh — 稳健长驱：state SSOT → apply(确定性) → gate → [cc repair] → commit
set -euo pipefail

LAB="$(cd "$(dirname "$0")/.." && pwd)"
REPO="$(git -C "$LAB" rev-parse --show-toplevel)"
TOOLS="$LAB/tools"
STATE_PY="$TOOLS/v4-longrun-state.py"
LOCK="$LAB/.build/v4-longrun.lock"
CC="${V4_LONGRUN_CC:-$HOME/.local/bin/cc-huoshan1-ds4pro}"
BATCHES="${V4_LONGRUN_BATCHES:-3}"
TIMEOUT="${V4_LONGRUN_TIMEOUT_SEC:-7200}"
GOAL="${V4_LONGRUN_GOAL:-}"
RETRIES="${V4_LONGRUN_RETRIES:-2}"
AUTO_COMMIT="${V4_LONGRUN_COMMIT:-1}"
export NANO_SLICE_COMPILER="${NANO_SLICE_COMPILER:-native}"

log() { printf '[v4-loop %s] %s\n' "$(date -u +%H:%M:%S)" "$*"; }
die() { log "FATAL: $*"; python3 "$STATE_PY" set-status failed 2>/dev/null || true; rm -f "$LOCK"; exit 1; }

acquire_lock() {
  mkdir -p "$LAB/.build"
  if [[ -f "$LOCK" ]]; then
    die "lock held: $LOCK (remove if stale)"
  fi
  echo $$ > "$LOCK"
  trap 'rm -f "$LOCK"' EXIT
}

read_wave() { python3 "$STATE_PY" get next_wave; }

goal_met() {
  local nw="$1"
  [[ -z "$GOAL" ]] && return 1
  [[ "$GOAL" == terminal* ]] && grep -qE '100%|~100%' "$LAB/v4/PROGRESS.md" 2>/dev/null && return 0
  [[ "$GOAL" =~ ^wave([0-9]+)$ ]] && (( nw > ${BASH_REMATCH[1]} )) && return 0
  return 1
}

apply_batch() {
  local lo="$1" hi="$2"
  log "apply wave${lo}-${hi} (deterministic)"
  python3 "$TOOLS/v4-apply-batch.py" "$lo" "$hi"
}

run_gate() {
  log "gate build+run.sh"
  bash "$LAB/build_nano_jit.sh"
  bash "$LAB/run.sh"
}

run_cc_repair() {
  local lo="$1" hi="$2"
  local task="$TOOLS/cc-task-repair-wave${lo}-${hi}.txt"
  [[ -x "$CC" ]] || command -v "$CC" >/dev/null || die "cc missing: $CC"
  cat > "$task" <<EOF
Gate failed after v4-apply-batch.py ${lo} ${hi}.
Fix lab/nano-lisp-jit until: export NANO_SLICE_COMPILER=native && bash build_nano_jit.sh && bash run.sh exits 0.
Do not commit. Final line: CC_DONE tests.pass=N
EOF
  log "cc repair wave${lo}-${hi}"
  "$CC" -p --dangerously-skip-permissions --add-dir "$LAB" --add-dir "$REPO/lab/lispjit-ir" \
    < "$task" 2>&1 | tee "/tmp/cc-repair-${lo}-${hi}.log"
  grep -q 'CC_DONE tests.pass=' "/tmp/cc-repair-${lo}-${hi}.log"
}

try_batch() {
  local lo="$1" hi="$2" a=1
  while (( a <= RETRIES )); do
    apply_batch "$lo" "$hi" || true
    if run_gate; then return 0; fi
    log "gate fail attempt $a — cc repair"
    run_cc_repair "$lo" "$hi" && run_gate && return 0
    a=$((a + 1))
  done
  return 1
}

commit_batch() {
  local lo="$1" hi="$2" tp="$3"
  cd "$REPO"
  git add lab/nano-lisp-jit lab/lispjit-ir/nano_bootstrap.c 2>/dev/null || git add -A lab/nano-lisp-jit
  git diff --cached --quiet && { log "nothing to commit"; return 0; }
  git commit -m "v4 wave${lo}-${hi}: longrun apply (tests.pass=${tp})"
  git push -u origin "$(git branch --show-current)" 2>/dev/null || true
}

acquire_lock
python3 "$STATE_PY" set-status running
START=$(date +%s)
done_batches=0

while (( done_batches < BATCHES )); do
  (( $(date +%s) - START >= TIMEOUT )) && die "timeout ${TIMEOUT}s"
  lo=$(read_wave)
  hi=$(( lo + 2 ))
  goal_met "$lo" && { log "GOAL $GOAL met"; python3 "$STATE_PY" set-status idle; exit 0; }

  log "=== batch $((done_batches+1))/$BATCHES waves $lo-$hi ==="
  try_batch "$lo" "$hi" || die "batch wave${lo}-${hi} failed"

  tp=$(grep -E '^tests\.pass=' "$LAB/.build/results.txt" | tail -1 | cut -d= -f2)
  python3 "$STATE_PY" bump "$lo" "$hi" "${tp:-0}"
  (( AUTO_COMMIT )) && commit_batch "$lo" "$hi" "${tp:-?}"
  log "OK tests.pass=${tp} next_wave=$((hi+1))"
  done_batches=$((done_batches + 1))
done

python3 "$STATE_PY" set-status idle
log "LOOP_OK batches=$done_batches next=$(read_wave)"
