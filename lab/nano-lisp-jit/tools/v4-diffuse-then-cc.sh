#!/usr/bin/env bash
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
  echo "started $s"
}

run_worker 1 "$DIR/w1-bootstrap-add161-177.txt"
run_worker 2 "$DIR/w2-elf64-onion-layer.txt"
run_worker 3 "$DIR/w3-bootstrap-onion-log.txt"
run_worker 4 "$DIR/w4-slices-166-174.txt"
run_worker 5 "$DIR/w5-slices-175-182.txt"
