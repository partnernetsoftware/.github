# Wave75 — full-runner-154kb（/goal nano-jit.com）

**签收**：`v45.goal.full_runner_154kb_continue.100=1`

| 槽 | plan | 扩散面 |
|----|------|--------|
| W1 | `goal-full-runner-genesis-pin-prove.lisp` | plan-only build-slice → **158392B** + smoke |
| W2 | `goal-full-runner-lisp-pack.lisp` | full x86 + ir aarch64 pack-ape |
| W3 | `goal-full-runner-gap-audit.lisp` | compose15 4096B vs genesis-pin 诚实 |
| W4 | `converge-daily-v45-full-runner-154kb.lisp` | daily |

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave75-full-runner-154kb-converge.sh
```

**诚实**：158KB 来自 genesis-pin 复制（regenesis 工厂更新 genesis）；非纯 compose15 codegen。
