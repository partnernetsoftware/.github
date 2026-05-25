# Wave25 — lisp runner codegen 探针（四轨）

在 Wave24 发行继续之上，并行跑 **lisp slice / ir-table** 探针（≠ 154KB 全量 C 替代）。

| 轨 | plan |
|----|------|
| W1 | `codegen-lisp-slice-min` |
| W2 | `codegen-lisp-slice-ir-exit` |
| W3 | `codegen-lisp-ir-table` |
| W4 | `mindmap-codegen-lisp-runner` + gen60 锚 |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave25-codegen-probe-converge.sh
grep v45.v45.codegen_probe.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

证据：`v45.codegen.lisp_runner_probe=1` · `v45.codegen.lisp_slices=3`
