# 物理终局 — 诚实口径

## v4.5 目标（未完成 ❌）

**`*.lisp` 自举 `nano-lisp.com`**，用户路径 plan 内无 `.c` / `.sh` / `.py`；终局态仓库无上述残留。

## 完成路径

| 阶段 | Wave | 用户 plan | 仓库诚实 |
|------|------|-----------|----------|
| 原生 bootstrap | 63 | ✅ | COM = `nano-lisp.com` |
| runner C 退仓 | 64 | ✅ | symlink 兼容 CI |
| CI 工具 sh 终局 | 65 | ✅ | wave converge 壳仍在 |
| factory lisp 退仓 | 66 | ✅ | wave66 `.sh` 壳仍在 |
| **wave sh 终局** | **67** | ✅ `daily_v45_com_plan_only_terminal` | **bootstrap 仍种子** |

## 签收（≠ DONE）

| 键 | 含义 |
|----|------|
| `v45.v45.wave_converge_shell_retire_continue.100=1` | Wave67 四轨 + wave sh 迁 retired |
| `v45.honest.wave_converge_shell_retired=1` | `scripts/` 零 active `.sh` |
| `v45.converge.daily_v45_com_plan_only_terminal=1` | 用户 daily 纯 COM+plan |
| `v45.physical.scripts_zero_active_sh=1` | 活跃 wave converge 壳已退 |

## 日常

```bash
# 用户路径（纯 COM+plan · Wave67）
COM=lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-com-plan-only-terminal.lisp

# CI 收敛（Wave67 后仅 retired 壳 · 诚实仍 host bash 一次）
bash lab/nano-lisp-jit/retired/scripts/v45-wave67-wave-converge-shell-retire-converge.sh
```

## 下一物理轨

Wave68：Lisp 自举链 promote 退种子 · 诚实终局冲刺
