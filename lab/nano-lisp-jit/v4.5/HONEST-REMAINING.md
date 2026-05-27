# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| 原生 bootstrap | 63 | ✅ | COM = `nano-lisp.com` |
| runner C 退仓 | 64 | ✅ | symlink 兼容 CI |
| CI 工具 sh 终局 | 65 | ✅ | wave converge 壳仍在 |
| **factory lisp 退仓** | **66** | ✅ `daily_v45_zero_archive_path` | **wave66 `.sh` 壳仍在** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.archive_factory_lisp_retire_continue.100=1` | Wave66 四轨 + factory lisp 迁 retired |
| `v45.honest.archive_factory_lisp_retired=1` | `archive/c/factory` → `retired/archive-c/factory` |
| `v45.converge.daily_v45_zero_archive_path=1` | 用户 daily 零 archive/c 路径 |
| `v45.honest.wave_converge_shell=1` | wave66 converge 壳仍在 CI |

## 日常

```bash
# 用户路径（零 archive 路径 · Wave66）
COM=lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-archive-path.lisp

# CI 收敛（host 外层 · 诚实仍 .sh）
bash lab/nano-lisp-jit/scripts/v45-wave66-archive-factory-lisp-retire-converge.sh
```

## 下一物理轨

Wave67：wave converge `.sh` 终局退 retired · 用户路径纯 COM+plan
