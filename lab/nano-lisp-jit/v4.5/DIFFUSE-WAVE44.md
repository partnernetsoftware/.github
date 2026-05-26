# Wave44 — nano-lisp-com-terminal（代际 semantic + 诚实零 C 卷）

广度环：semantic-terminal 之上，收束 **nano-lisp.com 终局 daily 入口**。

| 轨 | plan | 后台 |
|----|------|------|
| W1 | `nano-lisp-com-semantic-run.lisp` | engineer-a |
| W2 | `selfhost-nano-lisp-com-matrix.lisp` | engineer-b |
| W3 | `converge-daily-terminal.lisp` | engineer-a |
| W4 | `honest-zero-c-progress.lisp` | engineer-b |

```bash
# 快路径（默认）：seed wave43 键，只跑本 wave 四轨
bash lab/nano-lisp-jit/scripts/v45-wave44-nano-lisp-com-terminal-converge.sh

# 完整链（CI / 显式）
V45_FULL=1 bash lab/nano-lisp-jit/scripts/v45-wave44-nano-lisp-com-terminal-converge.sh

grep v45.v45.nano_lisp_com_terminal_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.nano_lisp_com.semantic_run=1` · `v45.selfhost.nano_lisp_com_matrix=1` · `v45.converge.daily_terminal=1`

**用户日常入口**：`converge-daily-terminal.lisp`

**诚实未达**：154KB C 物理替代 · `.com` 体内零 C · host 外层 `.sh`
