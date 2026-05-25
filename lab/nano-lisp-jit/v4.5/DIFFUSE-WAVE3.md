# Wave3 扩散 — 工厂 Lisp 化 · 一轮收敛

> **目标**：干掉 v45 的 `run.sh` 案例墙；plan 内无 `lispjit.c` 的代际自举；v4 wave 样本 **一次** 归档。

## 本波交付（已实施）

| 面 | 交付 |
|----|------|
| 收敛 | `scripts/v45-wave3-converge.sh` — 跑 **全部** `bootstrap-v45-*.lisp` |
| 无 C regenesis | `bootstrap-v45-wave3-lisp-only-regenesis.lisp` → `v45-w3-lisp-only.com` |
| run.sh | **单 case** `run-bootstrap-v45-wave3-converge-plan`（替代 ~35 个 v45 case） |
| 归档 | `tools/archive-v4-wave-samples.py` → `archive/samples/v4-waves/` |
| catalog | `verify` → `v45-wave3-converge.sh` |

## 证据键

| 键 | 含义 |
|----|------|
| `v45.wave3.diffuse=1` | Wave3 开卷 |
| `v45.wave3.plans=N` | 收敛跑的 plan 数 |
| `v45.lisp_only.regenesis=1` | plan 内零 `lispjit.c` 打 `.com` |
| `v45.factory.converge=1` | 工厂门禁迁 converge |
| `v45.scoped.100=1` | 发行面仍绿 |

## 收敛（唯一日常命令）

```bash
bash lab/nano-lisp-jit/scripts/v45-wave3-converge.sh
```

## Wave4 草图（仍是一波，勿碎砍）

| 面 | 一次扩散 |
|----|----------|
| tier3 | `lispjit.c` 移 `archive/runner/`；genesis 仍 pin |
| next 全矩阵 | `next.com` 跑 onion-tdd |
| squad | bootstrap `squad-dispatch` 去 `system(sh)` |
| CI | `tests.pass` 仅 terminal + v45-wave3-converge |
