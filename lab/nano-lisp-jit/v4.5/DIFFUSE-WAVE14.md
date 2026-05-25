# Wave14 — T5d VM emit 广度（四轨并发）

| 轨 | plan | 样本 |
|----|------|------|
| A | `wave14-vm-emit-arith` | `arithmetic.lisp` |
| B | `wave14-vm-emit-strlen` | `strlen.lisp` |
| C | `wave14-vm-emit-ctrl` | `control-flow.lisp` |
| D | `wave14-vm-emit-multi` | `multi-func.lisp` |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave14-vm-emit-converge.sh
```

证据：`v45.tier5.vm_emit_broad=1` · `v45.codegen.vm_emit_matrix=4`
