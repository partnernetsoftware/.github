# Wave38 — host 编排 Lisp 化（用户入口 plan-only）

> **编排**：主对话维护活图 → DP ready ≤4 → 后台四轨并发 → 一次 converge。

在 Wave37 之上，收束 **用户日常入口仅 `run-bootstrap-plan`**（host 外层 `.sh` 退居 CI/维护）。

| 轨 | 节点 | plan | 后台 |
|----|------|------|------|
| W1 | `v45-ho-converge-via-plan` | `bootstrap-v45-converge-via-plan.lisp` | engineer-a |
| W2 | `v45-ho-entry-plan` | `bootstrap-v45-entry-plan-only.lisp` | engineer-b |
| W3 | `v45-ho-com-primary` | `bootstrap-v45-nano-lisp-com-primary.lisp` | engineer-a |
| W4 | `v45-ho-gen-matrix` | `bootstrap-v45-selfhost-generation-matrix.lisp` | engineer-b |
| T/G | terminal + goal | mindmap-tree + goal-100 | reviewer |

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-host-orchestrator.json \
  python3 lab/nano-lisp-jit/tools/mindmap-dp-v45.py ready
bash lab/nano-lisp-jit/scripts/v45-wave38-host-orchestrator-converge.sh
grep v45.v45.host_orchestrator_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

证据：`v45.converge.via_plan=1` · `v45.entry.plan_only=1` · `v45.lisp_com.primary=1`

**诚实未达**：`.com` 体内 C · Wave39 runner 物理卷
