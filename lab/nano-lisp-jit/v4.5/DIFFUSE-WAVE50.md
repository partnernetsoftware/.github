# Wave50 — lispjit-codegen-dedicated（154KB 独立活图）

**独立活图**：不进发行面 rollup DONE；探针绿 ≠ 全量 C 替代。

| 轨 | plan |
|----|------|
| W1 | `runner-lispjit-154kb-codegen-probe.lisp` |
| W2 | `codegen-gen60-handshake-deep.lisp` |
| W3 | `converge-daily-codegen-dedicated.lisp` |
| W4 | `selfhost-codegen-154kb-deep-matrix.lisp` |

```bash
bash lab/nano-lisp-jit/scripts/v45-wave50-lispjit-codegen-dedicated-converge.sh
grep v45.v45.lispjit_codegen_dedicated_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.codegen.lispjit_154kb_probe=1` · `v45.codegen.gen60_handshake_deep=1`

**诚实**：`archive/c/runner/lispjit.c` 仍在 · 全量 codegen **未达**
