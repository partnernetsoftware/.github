#!/usr/bin/env bash
set -euo pipefail
CC="${V4_LONGRUN_CC:-$HOME/.local/bin/cc-huoshan1-ds4pro}"
DIR="/workspace/lab/nano-lisp-jit/tools/cc-diffuse"
TMUX_CFG="${TMUX_CFG:-/exec-daemon/tmux.portal.conf}"
for id in 1 2 3; do
  s="cc-diffuse-w${id}"
  task="$DIR/w1-bootstrap-add178-194.txt"
  [ "$id" = "2" ] && task="$DIR/w2-fast-emit.txt"
  [ "$id" = "3" ] && task="$DIR/w3-fast-boot.txt"
  tmux -f "$TMUX_CFG" has-session -t "=$s" 2>/dev/null && tmux -f "$TMUX_CFG" kill-session -t "$s" || true
  tmux -f "$TMUX_CFG" new-session -d -s "$s" -c "/workspace" -- bash -l -c \
    "export PATH=\"\$HOME/.local/bin:\$PATH\" && $CC -p --dangerously-skip-permissions --add-dir lab/lispjit-ir --add-dir lab/nano-lisp-jit < \"$task\" 2>&1 | tee /tmp/cc-diffuse-w${id}.log; echo EXIT:\$?"
  echo "w$id"
done
