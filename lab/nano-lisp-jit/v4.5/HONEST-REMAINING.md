# 物理终局 — 诚实口径

## v4.5 用户路径（✅ 2026-05-27）

```bash
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-genesis-pin.lisp
```

## /goal nano-jit.com · Wave76（当前）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-zero-genesis-pin.json \
  python3 lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py ready
bash lab/nano-lisp-jit/retired/scripts/v45-wave76-zero-genesis-pin-converge.sh
```

**突破**：plan 内 `build-slice-compile` → **158392B** · 零 genesis-pin

## Wave75（已签收）

```bash
NANO_V45_FRONTIER=mindmap-frontier-v45-compose15-runner-promote.json \
  python3 lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py ready
bash lab/nano-lisp-jit/retired/scripts/v45-wave72-compose15-runner-promote-converge.sh
```

## Wave71（已签收）

```bash
# v45.v45.lisp_codegen_diffuse_continue.100=1
bash lab/nano-lisp-jit/retired/scripts/v45-wave71-lisp-codegen-diffuse-converge.sh
```

| 项 | 状态 |
|----|------|
| 用户 daily plan 零 `.c`/`.sh`/`.py`/`archive/c` 步骤 | ✅ |
| `release/nano-lisp.com` 进仓 + manifest pin | ✅ |
| verify-smoke / core / all / entry / onion-tdd | ✅（`v45-terminal-com-promote.sh`） |
| aarch64 slice | **154KB**（原 genesis 648KB 已消） |

## 仍开卷（工厂 · 非用户路径）

| 项 | 说明 |
|----|------|
| 6 面 APE | 2/6 Linux only |
| `build_nano_jit.sh` 工厂 | `archive/c/runner/` 编译 · genesis pin 仍用于 `(build-slice lispjit.c …)` |
| CI `run.sh` + `retired/scripts/*.sh` | 工厂面 |

## 终局收敛

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-terminal-com-promote.sh
grep v45.v45.terminal_done=1 lab/nano-lisp-jit/.build/v45-entry.evidence.canonical
```

## 签收

| 键 | 含义 |
|----|------|
| `v45.v45.terminal_done=1` | COM promote + 矩阵绿 |
| `v45.v45.terminal_com_promoted=1` | release/ 已更新 |
| `v45.honest.aarch64_slim_slice=1` | 双架构 154KB slice |
| `v45.v45.compose15_runner_promote_continue.100=1` | Wave72 compose15 promote 续推 |
| `v45.goal.zero_genesis_pin_continue.100=1` | Wave76 build-slice-compile 158KB（零 genesis-pin） |
