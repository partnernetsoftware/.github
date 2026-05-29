# Wave78 — compose15-full-codegen（/goal nano-jit.com）

**签收**：`v45.goal.compose15_full_codegen_continue.100=1`

| 槽 | plan | 扩散面 |
|----|------|--------|
| W1 | `probe-compose15-pure-link.lisp` | 纯 link 4096B · 零 host cc 回退 |
| W2 | `goal-compose15-full-codegen-gap-audit.lisp` | pure 445B code vs hybrid 158KB 诚实 |
| W3 | `goal-compose15-object-sum-prove.lisp` | 15 TU object 求和 + exit 42 |
| W4 | `converge-daily-v45-compose15-full-codegen.lisp` | daily |

**突破**：`NANO_COMPOSE15_NO_HYBRID=1` 可探针纯 compose15 link · 量化 codegen 缺口

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave78-compose15-full-codegen-converge.sh
```

**诚实**：15 模块 stub 链 link.code≈445B、file≈4096B；158KB 仍依赖 hybrid host cc 或模块扩面。
