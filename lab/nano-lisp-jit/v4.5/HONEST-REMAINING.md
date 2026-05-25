# 物理终局 — 诚实剩余（不冒充 100%）

> **已签收**（有证据键、有口径）：`v45.scoped.100` · `v45.release.100` · `v45.endgame.100`（DECISION tier0–4）· `v45.factory.100`（须 `NANO_V45_SCOPED_ONLY=1`）。  
> **未签收**：全仓零 `.c`、默认瘦 `run.sh`、154KB runner 全 Lisp codegen。

## 证据键诚实表

| 键 | 可声称 | 不可声称 |
|----|--------|----------|
| `v45.scoped.100=1` | 洋葱 TDD + com-only 发行面 | 全仓无 `.sh` |
| `v45.endgame.100=1` | DECISION 文档 tier0–4 | 删光 `nano_*.c` |
| `v45.warehouse.100=1` | endgame+factory **合卷**（scoped 栈） | **全仓物理终局** |
| `v45.physical.zero_c=0` | 明示 **未完成** | — |
| `v45.honest.tier5.open=1` | tier5 开卷 | tier5 完成 |

## Tier5 目标（物理，未开完）

| ID | 完成定义 | 当前 |
|----|----------|------|
| T5a | 日常 `run.sh` 默认走发行面（`v45-release-run.sh` 或 env 默认） | Wave10 锚点 |
| T5b | `lispjit-ir` 仅 symlink/桩，真源仅在 `archive/` | 仅 `lispjit.c` 迁出 |
| T5c | 仓内 `.c` 计数下降且文档化 | 未做 |
| T5d | VM emit 全量替代 C 表 | tier4 仅 smoke |

## 日常命令（发行面真源）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave9-converge.sh
# 或 Wave10：
bash lab/nano-lisp-jit/scripts/v45-wave10-honest-converge.sh
```

## 工厂瘦身（须显式 env，非默认 run.sh）

```bash
NANO_V45_SCOPED_ONLY=1 bash lab/nano-lisp-jit/scripts/v45-release-run.sh
```
