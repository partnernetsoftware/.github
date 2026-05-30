# Wave73 — /goal nano-jit.com（扩散 · 四轨并发）

**签收**：`v45.goal.nano_jit_com.continue.100=1`（≠ 终局 DONE）

| 槽 | plan | 扩散面 |
|----|------|--------|
| W1 | `goal-nano-jit-com-regenesis-probe.lisp` | 工厂 regenesis slice 尺寸探针 |
| W2 | `goal-nano-jit-com-matrix.lisp` | release COM + verify 矩阵 |
| W3 | `goal-nano-jit-com-lisp-regenesis-pack.lisp` | plan 零 lispjit.c · pack COM |
| W4 | `goal-nano-jit-com-154kb-gap-audit.lisp` | compose15 stub vs 154KB 诚实 |

**活图 journal**：[`mindmap-goal-nano-jit-com.json`](mindmap-goal-nano-jit-com.json)

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-nano-jit-com-goal.json \
  python3 lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py ready

bash lab/nano-lisp-jit/retired/scripts/v45-wave73-nano-jit-com-goal-converge.sh
```

**严格 DONE 仍需**：Lisp-only 154KB full runner · 非 genesis-pin 工厂独占
