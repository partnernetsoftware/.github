# v3.5 — 冻结（待 v3 完全 100%）

**Status: 不启动** — 在 v3 slice **4b-3**（全量 `lispjit.c` 零 host `cc`）签收前，本目录仅保留规划 mindmap，**不实现**。

## 门禁

| 条件 | 状态 |
|------|------|
| v3 core（slice 0–3） | **100%** |
| v3 slice 4 编排（gen1→gen2） | **100%** |
| v3 slice 4b-1 `build-slice-lisp` | **100%** |
| v3 slice 4b-2 `nano-cc` hello | **100%** |
| v3 slice 4b-3 全量 `lispjit.c` codegen | **0%** ← **阻塞 v3.5** |

v3 完全 100% = 上表全部 **100%**。当前缺口见 [`../v3/CODEGEN.md`](../v3/CODEGEN.md)。

## v3.5 启动后做什么

原 v3.5 范围（`nano-cc` 扩展、全量 TU、`NANO_REGENESIS` pin 等）见 [`../ROADMAP.md`](../ROADMAP.md) → **v3.5 洋葱 TDD mindmap**。与 4b-3 重叠部分将在 v3 内先完成，v3.5 仅承接 **v4+ 外部语义** 或超出 slice compiler 的扩展。

## 当前请做

在 **v3** 分支继续 **slice 4b-3**，不要在本目录开工。
