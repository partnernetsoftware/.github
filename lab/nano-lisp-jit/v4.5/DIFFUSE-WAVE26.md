# Wave26 — codegen 探针扩面（五轨）

在 Wave25 之上，并行 **VM emit arith/strlen** + **next-lo 最小 onion**（≠ 154KB 全量 C 替代）。

| 轨 | plan |
|----|------|
| W1 | `codegen-lisp-vm-arith` |
| W2 | `codegen-lisp-vm-strlen` |
| W3 | `onion-next-lo-minimal` |
| W4 | `mindmap-codegen-expand` + goal 锚 |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave26-codegen-expand-converge.sh
grep v45.v45.codegen_expand.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

证据：`v45.codegen.lisp_slices=5` · `v45.factory.next_lisp_only_onion_minimal=1`
