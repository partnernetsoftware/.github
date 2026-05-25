# v4.5 清理记录（2026-05-24）

## 做了什么

| 动作 | 前 | 后 |
|------|-----|-----|
| SLICE 文档 | `archive/v4/slices/SLICE*.md`（244） | `archive/v4/slices/` |
| 工厂长文 | `v4/LONG-RUN-TODO` 等 | `archive/v4/factory-docs/` |
| 路径批量更新 | — | `run.sh`、samples、catalog、tools（439+ 文件） |
| `v4/` 活跃文档 | ~260 md | **16** + [`INDEX.md`](../v4/INDEX.md) |

## 未动（刻意）

| 路径 | 原因 |
|------|------|
| `samples/bootstrap-v4-wave*.lisp`（662） | `run.sh` 硬编码变量，迁一动千 |
| `samples/bootstrap-v4-zero-host-*` | zero-host / lispjit 证据链 |
| `run.sh` / `lispjit-ir/*.c` | 开发工厂 |
| `.build/` | 已 gitignore |

## 目录真源

见 [`../STRUCTURE.md`](../STRUCTURE.md) · 样例见 [`../samples/README.md`](../samples/README.md)

## 验收

```bash
test -f lab/nano-lisp-jit/archive/v4/slices/SLICE252.md
test -f lab/nano-lisp-jit/v4/PROGRESS.md
! test -f lab/nano-lisp-jit/archive/v4/slices/SLICE252.md
```

证据键（可选）：`v45.cleanup.ok=1`
