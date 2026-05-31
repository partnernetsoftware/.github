# Wave90 — proc-io（read-file · spawn-wait · factory rebuild）

**签收**：`v45.goal.proc_io=1` · `v45.goal.proc_io_continue.100=1`

| 槽 | 交付 | 扩散面 |
|----|------|--------|
| W1 | `nano_bootstrap.c` + `nano_run_cli.c` | `(read-file path)` · `(spawn-wait expected exe [argv...])` |
| W2 | `bootstrap-v45-proc-io.lisp` | manifest/evidence 读 · `/bin/sh -c` argv spawn |
| W3 | factory cc rebuild | `.build/nano-jit/nano-jit.x86_64` |
| W4 | journal round 19 | frontier 4/4 |

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave90-proc-io-converge.sh
```

**说明**：release `nano-lisp.com` 待 cosmocc promote 后携带新原语；Wave90 用 factory cc slice 验收。

**下一波 preview**：wave91 — release COM promote + bulk→语义 codegen
