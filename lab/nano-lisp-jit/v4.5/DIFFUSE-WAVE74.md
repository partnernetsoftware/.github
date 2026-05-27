# Wave74 — regenesis-promote（/goal nano-jit.com）

**签收**：`v45.goal.regenesis_promote_continue.100=1`

| 槽 | plan | 扩散面 |
|----|------|--------|
| W1 | `goal-nano-jit-com-regenesis-promote.lisp` | genesis 158KB + release COM |
| W2 | `probe-compose15-regenesis-build-slice.lisp` | compose-15link env 探针 OK |
| W3 | `goal-nano-jit-com-release-matrix.lisp` | verify-smoke + inspect |
| W4 | `converge-daily-v45-regenesis-promote.lisp` | daily 升维 |

**Round2 突破**：`build_nano_jit.sh -I lab/lispjit-ir` · regenesis slice **158392B** · COM **318137B**

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-regenesis-promote.json \
  python3 lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py ready
bash lab/nano-lisp-jit/retired/scripts/v45-wave74-regenesis-promote-converge.sh
```
