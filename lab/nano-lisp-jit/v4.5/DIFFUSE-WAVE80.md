# Wave80 — compose15-module-expand（/goal nano-jit.com · L4）

**签收**：`v45.goal.compose15_module_expand_continue.100=1`

| 槽 | plan | 扩散面 |
|----|------|--------|
| W1 | `probe-compose15-expand-pure-link.lisp` | compose-15link-expand · NO_HYBRID |
| W2 | `goal-compose15-module-expand-gap-audit.lisp` | stub vs expand object_bytes |
| W3 | `goal-compose15-module-expand-prove.lisp` | plan-only expand 15link |
| W4 | daily |

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave80-compose15-module-expand-converge.sh
```

**诚实**：Wave80 扩面 object_bytes；158KB 纯 lisp 仍开卷。
