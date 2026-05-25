# samples 目录梳理

## 发行面（v4.5 · 优先）

| 前缀 / 目录 | 数量级 | 用途 |
|-------------|--------|------|
| `bootstrap-v45-*.lisp` | ~13 | 洋葱 TDD、verify、boundary、DONE |
| `boundary/*.lisp` | 10 | 能力边界探测（+ 负向 plan） |
| `*.lisp`（根） | ~30 | VM/AOT 核心样例（arithmetic、strlen、…） |
| `lispjit-modules/` | 13 | lispjit-from-lisp 模块 TU |

验收：[`../v4.5/ONION-TDD.md`](../v4.5/ONION-TDD.md)

## v4 工厂（维护 · 勿删）

| 前缀 | 数量级 | 用途 |
|------|--------|------|
| `bootstrap-v4-zero-host-*` | ~60 | 零宿主 gen2–gen60 |
| `bootstrap-v4-wave*` | ~660 | 波次 tick / diffusion |
| `bootstrap-v4-slice*-evidence` | ~90 | slice 证据 rollup |
| `nano-jit-slice-add-*` | ~80 | addNN aarch64 切片 |

由 `run.sh` 全量回归；**用户路径不经过此目录全部文件**。

## 命名约定

- `bootstrap-v45-*` — 发行面 plan（无 `.c`）
- `bootstrap-v4-zero-host-*` — 自举链
- `bootstrap-v4-waveNN-*` — 历史波次（归档语义，仍在仓内）
