# v4 反思 · 调整 · post-scoped 推进

**前提**：[`COMPLETE-SCOPED.md`](COMPLETE-SCOPED.md) 已闭合洋葱 **scoped 圈**；本文 **不声称** 零 `.c` / `.py` / `.sh` 或完全自举。

## 1. 反思（诚实）

| 误判风险 | 事实 |
|----------|------|
| 「v4 完成 = 零 C」 | 仅 **plan 层** 可不引用 `.c`；runner/codegen 仍是 C |
| 「scoped 100% = 可删 run.sh」 | 门禁与证据仍靠 host `run.sh` / squad |
| 「并行 = agent-team 更快」 | 无 LLM 的 tmux 只跑状态机；**双轨单 Agent + 一次 verify** 更快 |
| 「表驱动 emit = IR codegen」 | 表在 C 里；不是 Lisp VM 发射 |

## 2. 调整（post-v4 策略）

```text
洋葱圈 post-v4（wave21+）
├─ C1 codegen：emit 全路径仅经表（table-only 可观测）→ add18 回归
├─ O1 编排：build-graph bootstrap 多步 + squad-done 契约样本
├─ T1 terminal：dev container 跑满 build；cloud 只卡 scoped
└─ 终局轨（未开卷）：Lisp squad FFI · nano-cc 子集 · .com 自举
```

| 原则 | 做法 |
|------|------|
| **并行** | 轨 A 只碰 `nano_*.c`；轨 B 只碰 `bootstrap-v4-squad-*` / `v4/*.md` |
| **签收** | 仍用 `v4-complete-scoped` + 增 gate；不抬高「零宿主」叙事 |
| **verify** | 波末一次 `bash lab/nano-lisp-jit/run.sh`；禁止空转 agent-team |

## 3. wave21 交付（本波）

| 轨 | 任务 | 交付 |
|----|------|------|
| A | `wave21-v4-emit-table-only` | `aarch64.emit.encode=table-only` + add18 |
| B | `wave21-v4-build-graph` | `bootstrap-v4-build-graph-smoke.lisp` |
| B | `wave21-v4-squad-done` | `bootstrap-v4-squad-s9-done.lisp` |

## 4. wave22（本波）

| 轨 | 交付 |
|----|------|
| 编排 | `bootstrap-v4-squad-assess-scoped-ready.lisp` — catalog + COMPLETE-SCOPED 锚点 |
| 文档 | `v4/README.md` 代码地图（Plan / Runner / Codegen） |

## 5. 下一刀（wave23 草图）

- **terminal**：`build_nano_jit.sh` 证据进 bootstrap plan（dev container / cosmocc）
- **codegen**：IR 字表由 plan 内 u64 常量列出（仍由 C 读入，但契约在 Lisp）
