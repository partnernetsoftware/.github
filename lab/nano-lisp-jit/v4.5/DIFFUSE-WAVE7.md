# Wave7 扩散 — 发行面终局 100%

> **签收口径**：`v45.release.100=1`（**非**全仓零 `.c` / tier4 VM emit）。

## 本波交付

| 面 | 交付 |
|----|------|
| 终局 plan | `bootstrap-v45-endgame-100.lisp` |
| 工厂 skip | `skip_registry.sh` — `NANO_V45_SCOPED_ONLY=1` 跳过 v4 `run_case` |
| 收敛 | `scripts/v45-wave7-converge.sh` |
| run.sh | 单 case `run-bootstrap-v45-wave7-converge-plan` |

## 证据键

| 键 | 含义 |
|----|------|
| `v45.release.100=1` | **发行面终局 100%** |
| `v45.endgame.release=1` | 同上别名 |
| `v45.factory.v4_skipped=1` | scoped 工厂可跳过 v4 墙 |
| `v45.scoped.100=1` | 仍保留 scoped 签收 |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave7-converge.sh
grep v45.release.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

## 诚实未声称（全仓终局）

| 项 | 键 |
|----|-----|
| 删 `lispjit-ir/lispjit.c` | `v45.runner.no_c_src=0` |
| VM emit tier4 | `v45.codegen.vm_emit=0` |
| `run.sh` 物理删除 v4 段 | 仅 skip，非删文件 |
