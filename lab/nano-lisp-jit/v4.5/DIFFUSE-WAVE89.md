# Wave89 — proc-smoke（dogfooding · plan 级子进程 / 制品 I/O）

**签收**：`v45.goal.proc_smoke=1` · `v45.goal.proc_smoke_continue.100=1`

| 槽 | plan | 扩散面 |
|----|------|--------|
| W1 | `bootstrap-v45-proc-smoke.lisp` | emit ELF + `run-expect-exit` 链 · `/bin/true` · file-size/hash |
| W2 | `bootstrap-v45-goal-proc-smoke.lisp` | release inspect + strict_done 门禁保持 |
| W3 | daily | `converge-daily-v45-proc-smoke.lisp`（可选） |
| W4 | journal | round 18 · frontier 4/4 |

**背景**：Wave88 `strict_done` 后，用真实 `*.lisp` plan 驱动 **进程编排** 能力；`run-expect-exit` 已封装 fork/exec/waitpid，本波先 dogfood 再排 `read-file`/`spawn-wait` 引擎原语。

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave89-proc-smoke-converge.sh
```

**下一波 preview**：wave90 — `read-file` bootstrap 原语 + COM 工厂 rebuild；bulk → 真实语义模块
