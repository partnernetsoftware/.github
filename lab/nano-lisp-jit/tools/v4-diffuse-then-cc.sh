#!/usr/bin/env bash
# 阶段2: ≤5 路 cc 并行（阶段1 由 Commander: gen-v4-wave-batch.py LO HI）
set -euo pipefail
CC="${V4_LONGRUN_CC:-$HOME/.local/bin/cc-huoshan1-ds4pro}"
DIR="/workspace/lab/nano-lisp-jit/tools/cc-diffuse"
TMUX_CFG="${TMUX_CFG:-/exec-daemon/tmux.portal.conf}"

run_worker() {
  local id=$1 task=$2
  local s="cc-diffuse-w${id}"
  tmux -f "$TMUX_CFG" has-session -t "=$s" 2>/dev/null && tmux -f "$TMUX_CFG" kill-session -t "$s" || true
  tmux -f "$TMUX_CFG" new-session -d -s "$s" -c "/workspace" -- bash -l -c \
    "export PATH=\"\$HOME/.local/bin:\$PATH\" && $CC -p --dangerously-skip-permissions --add-dir lab/nano-lisp-jit --add-dir lab/lispjit-ir < \"$task\" 2>&1 | tee /tmp/cc-diffuse-w${id}.log; echo EXIT:\$?"
  echo "started $s <- $task"
}

run_worker 1 "$DIR/w1-bootstrap-add144-160.txt"
run_worker 2 "$DIR/w2-elf64-emit-profile.txt"
run_worker 3 "$DIR/w3-bootstrap-verify-log.txt"
run_worker 4 "$DIR/w4-slices-149-156.txt"
run_worker 5 "$DIR/w5-slices-157-165.txt"
