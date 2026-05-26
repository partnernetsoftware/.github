# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| lispjit.c 迁出 | 57 | ✅ | active C 已删 |
| wave .sh 迁出 | 58 | ✅ | wave converge 已删 |
| tools .py 迁出 | 59 | ✅ | active py 已删 |
| CI shell 终局 | 60 | ✅ | **`physical.zero_cpysh=1`** |
| 原生 bootstrap | 63 | ✅ | COM = `nano-lisp.com` |
| **runner C 退仓** | **64** | ✅ `daily_v45_lisp_only_factory` | **factory lisp 仍在 archive/c** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.archive_c_factory_retire_continue.100=1` | Wave64 四轨 + runner C 迁 retired |
| `v45.honest.archive_c_runner_retired=1` | `archive/c/runner` → `retired/archive-c/runner` |
| `v45.converge.daily_v45_lisp_only_factory=1` | 用户 daily 零 `archive/c` 路径 |
| `v45.physical.zero_cpysh=1` | active 发行面树零 c/sh/py |

## 日常

```bash
# bootstrap 宿主 + daily（Wave64 · lisp-only factory）
COM=lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-lisp-only-factory.lisp
bash lab/nano-lisp-jit/scripts/v45-wave64-archive-c-factory-retire-converge.sh
```

## 下一物理轨

Wave65：CI 工具 `.sh` 终局退 retired · 用户路径纯 plan
