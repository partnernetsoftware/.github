#!/usr/bin/env bash
# 洋葱 TDD 阶段 2 · Cursor Agent CLI（替代 cc-huoshan，≤3 路 tmux）
# 需 CURSOR_API_KEY 或 agent login；任务见 tools/agent-diffuse/
set -euo pipefail
AGENT="${V4_LONGRUN_AGENT:-$HOME/.local/bin/agent}"
DIR="/workspace/lab/nano-lisp-jit/tools/agent-diffuse"
TMUX_CFG="${TMUX_CFG:-/exec-daemon/tmux.portal.conf}"
if ! "$AGENT" -p --trust -f "echo ok" >/dev/null 2>&1; then
  echo "agent CLI 未认证：设置 CURSOR_API_KEY 或运行 agent login" >&2
  exit 2
fi
for id in 1 2 3; do
  s="agent-diffuse-w${id}"
  task="$DIR/w1-bootstrap-add206-219.txt"
  [ "$id" = "2" ] && task="$DIR/w2-cli-emit.txt"
  [ "$id" = "3" ] && task="$DIR/w3-cli-boot.txt"
  tmux -f "$TMUX_CFG" has-session -t "=$s" 2>/dev/null && tmux -f "$TMUX_CFG" kill-session -t "$s" || true
  tmux -f "$TMUX_CFG" new-session -d -s "$s" -c "/workspace" -- bash -l -c \
    "export PATH=\"\$HOME/.local/bin:\$PATH\" && $AGENT -p --trust --force --workspace /workspace < \"$task\" 2>&1 | tee /tmp/agent-diffuse-w${id}.log; echo EXIT:\$?"
  echo "w$id -> $task"
done
