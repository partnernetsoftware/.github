# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| lispjit.c 迁出 | 57 | ✅ | active C 已删 |
| wave .sh 迁出 | 58–64 | ✅ | wave converge 已删 |
| tools .py 迁出 | 59 | ✅ | active py 已删 |
| 原生 bootstrap | 63 | ✅ | COM = `nano-lisp.com` |
| runner C 退仓 | 64 | ✅ | factory lisp 仍在 archive/c |
| **CI 工具 sh 终局** | **65** | ✅ `daily_v45_plan_only_final` | **wave65 `.sh` 壳仍在** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.ci_sh_final_retire_continue.100=1` | Wave65 四轨 + CI 工具 sh 迁 retired |
| `v45.ci.utility_sh_retired=1` | `v45-com-verify` 等已迁 `retired/scripts/` |
| `v45.converge.daily_v45_plan_only_final=1` | 用户 daily 纯 plan |
| `v45.honest.wave_converge_shell=1` | wave65 converge 壳仍在 CI |

## 日常

```bash
# 用户路径（纯 plan · Wave65）
COM=lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-plan-only-final.lisp

# CI 收敛（host 外层 · 诚实仍 .sh）
bash lab/nano-lisp-jit/scripts/v45-wave65-ci-sh-final-retire-converge.sh
```

## 下一物理轨

Wave66：`archive/c/factory` lisp 物理退仓 · 全 monorepo 零 archive 路径
