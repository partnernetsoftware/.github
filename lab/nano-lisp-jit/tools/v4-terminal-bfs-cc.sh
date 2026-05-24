#!/usr/bin/env bash
# 终局 BFS 阶段 2 · ≤4 × cc-huoshan（填 loader/pack/com 细节）
set -euo pipefail
CC="${V4_LONGRUN_CC:-$HOME/.local/bin/cc-huoshan1-ds4pro}"
DIR="/workspace/lab/nano-lisp-jit/tools/terminal-bfs-cc"
TMUX_CFG="${TMUX_CFG:-/exec-daemon/tmux.portal.conf}"
mkdir -p "$DIR"
for id in 1 2 3 4; do
  s="terminal-bfs-w${id}"
  task="$DIR/w1-ape-payload-load.txt"
  [ "$id" = "2" ] && task="$DIR/w2-com-plan-review.txt"
  [ "$id" = "3" ] && task="$DIR/w3-mindmap-bfs.txt"
  [ "$id" = "4" ] && task="$DIR/w4-boot-anchor.txt"
  tmux -f "$TMUX_CFG" has-session -t "=$s" 2>/dev/null && tmux -f "$TMUX_CFG" kill-session -t "$s" || true
  tmux -f "$TMUX_CFG" new-session -d -s "$s" -c "/workspace" -- bash -l -c \
    "export PATH=\"\$HOME/.local/bin:\$PATH\" && $CC -p --dangerously-skip-permissions --add-dir lab/lispjit-ir --add-dir lab/nano-lisp-jit < \"$task\" 2>&1 | tee /tmp/terminal-bfs-w${id}.log; echo EXIT:\$?"
  echo "w$id"
done
