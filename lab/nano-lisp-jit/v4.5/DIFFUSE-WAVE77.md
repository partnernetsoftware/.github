# Wave77 — release-promote-compile-com（/goal nano-jit.com）

**签收**：`v45.goal.release_promote_compile_com_continue.100=1`

| 槽 | plan | 扩散面 |
|----|------|--------|
| W1 | `goal-release-promote-compile-prove.lisp` | release COM + manifest 验收 |
| W2 | `probe-compose15-hybrid-fallback.lisp` | compose15 stub → **158KB** hybrid |
| W3 | `goal-zero-pin-com-release-promote.lisp` | zero-pin COM pack + promote |
| W4 | `converge-daily-v45-release-promote-compile-com.lisp` | daily |

**突破**：compose15 link 后 `<16KB` 自动 `build-slice-compile` 回退 · release 矩阵全绿

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave77-release-promote-compile-com-converge.sh
```

**诚实**：hybrid 回退仍调 host cc；非纯 lisp 模块 codegen 158KB。
