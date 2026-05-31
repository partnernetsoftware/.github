# Wave91 — proc-io release promote（native regenesis · 326K COM）

**签收**：`v45.goal.proc_io_release=1` · `v45.goal.proc_io_release_promote=1`

| 槽 | 交付 | 扩散面 |
|----|------|--------|
| W1 | gate wave90 | `v45.goal.proc_io=1` |
| W2 | `NANO_SLICE_COMPILER=native NANO_REGENESIS=1 build_nano_jit.sh` | `.build/nano-jit/nano-jit.com` |
| W3 | promote → `release/nano-lisp.com` | manifest pin · parity |
| W4 | 并行矩阵 | proc-io · strict-done · verify-all/entry/onion-tdd |
| W5 | journal round 20 | frontier 5/5 |

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave91-release-promote-converge.sh
```

**事实**：release COM ~326345B · slice ~162496B（含 read-file/spawn-wait）；genesis 154KB bulk 仍双轨。

**下一波 preview**：wave92 — bulk stub → 真实语义 codegen · genesis 同源
