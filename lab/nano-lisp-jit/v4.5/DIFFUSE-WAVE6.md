# Wave6 扩散 — 洋葱主门禁 · w3 探针 · 工厂 slim

> **目标**：澄清 `v45-w3-lisp-only.com` 语义；发行面洋葱以 `onion-lisp-only` 为主；提供 `NANO_V45_SCOPED_ONLY` 工厂瘦身入口。

## 本波交付

| 面 | 交付 |
|----|------|
| 洋葱主 | `ONION-TDD.md` 优先 `onion-lisp-only.lisp` |
| w3 探针 | `wave6-w3-minimal-probe` — `run-ape-expect-exit` 42 |
| 产品反馈 | `PRODUCT-FEEDBACK.md` **B09** |
| 工厂 slim | `scripts/v45-factory-slim.sh` + `NANO_V45_SCOPED_ONLY=1` |
| 收敛 | `scripts/v45-wave6-converge.sh`（内嵌 wave5） |

## 证据键

| 键 | 含义 |
|----|------|
| `v45.wave6.diffuse=1` | Wave6 开卷 |
| `v45.onion.primary_lisp_only=1` | 洋葱主门禁锚点 |
| `v45.w3_com.minimal_probe=1` | w3 slice 探针绿 |
| `v45.factory.slim=1` | factory slim 脚本就绪 |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave6-converge.sh
```

工厂瘦身（不跑 v4 1200 case）：

```bash
NANO_V45_SCOPED_ONLY=1 bash lab/nano-lisp-jit/scripts/v45-factory-slim.sh
```

## 诚实未声称

- `run.sh` 内 v4 case 未自动 skip（须用 `v45-factory-slim.sh` 或 env 约定）
- tier3 删 `lispjit.c` · tier4 VM emit 未开
