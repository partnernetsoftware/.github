# 洋葱 TDD · 先扩散后并发（V4 提速）

**与** [`MINDMAP.md`](MINDMAP.md) **不冲突**：洋葱圈仍由外向内；**每批**先整图扩散，再并发填肉。

## 两阶段

```text
阶段 1 · 扩散（Commander + gen，分钟级）
  一次 gen WAVES N..M → samples / run.sh / catalog / SLICE 骨架 / index
  不碎补、不每波 gate

阶段 2 · 并发细节（≤5 × cc-huoshan，Worker Pool）
  按 touch 文件分片，互不踩：
    W1 bootstrap add 链
    W2 nano_elf64 emit
    W3 nano_bootstrap 可观测
    W4 SLICE 洋葱文档 A
    W5 SLICE 洋葱文档 B

阶段 3 · 收敛（Critic，一次）
  turbo gate：build + run.sh → bump state → EVAL/PROGRESS → 合 main
```

## 调度

| 任务 | 谁 |
|------|-----|
| 框架 / WAVES / 任务树 | Commander |
| C / run.sh 碎活 | cc × ≤5 |
| 门禁 / 诚实进度 | Critic + skill gate |
| 指针 | Memory = `longrun-state.json` |

见 [`DEV-AGENTS-TEAM.md`](DEV-AGENTS-TEAM.md)。
