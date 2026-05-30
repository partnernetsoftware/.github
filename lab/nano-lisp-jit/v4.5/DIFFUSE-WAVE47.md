# Wave47 — zero-host-sh-terminal（host .sh 退居 CI + plan 全收敛终局）

广度环：runner-codegen-terminal 之上，收束 **用户路径 plan-only**；`.sh` 仅 CI/维护。

| 轨 | plan | 后台 |
|----|------|------|
| W1 | `converge-plan-only-terminal.lisp` | engineer-a |
| W2 | `host-sh-ci-boundary.lisp` | engineer-b |
| W3 | `converge-daily-zero-host-sh.lisp` | engineer-a |
| W4 | `selfhost-plan-only-terminal-matrix.lisp` | engineer-b |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave47-zero-host-sh-terminal-converge.sh
grep v45.v45.zero_host_sh_terminal_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.converge.plan_only_terminal=1` · `v45.honest.host_sh_ci_only=1` · `v45.converge.daily_zero_host_sh=1`

**用户日常入口**：`converge-daily-zero-host-sh.lisp`（**无 `.sh` 步骤**）

**诚实未达**：CI 仍调用 `scripts/v45-*.sh` · 154KB C 物理替代
