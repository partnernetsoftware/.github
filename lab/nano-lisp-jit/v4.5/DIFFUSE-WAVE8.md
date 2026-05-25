# Wave8 扩散 — tier3 + tier4 → `v45.endgame.100`

> **签收**：`v45.endgame.100=1` = release 100% + tier3 `no_c_src` + tier4 `vm_emit`

## 本波交付

| 面 | 交付 |
|----|------|
| tier3 | `lispjit.c` 真源迁至 `archive/runner/`；`lispjit-ir/lispjit.c` 仅为 symlink |
| tier4 | `bootstrap-v45-tier4-vm-emit.lisp` — `ir-table-lisp` + VM/AOT smoke |
| 收敛 | `scripts/v45-wave8-converge.sh` |
| 工厂 | `run.sh` / `build_nano_jit.sh` → `archive/runner/lispjit.c` |

## 证据键

| 键 | 含义 |
|----|------|
| `v45.endgame.100=1` | **DECISION 全 tier 0–4 发行面终局** |
| `v45.runner.no_c_src=1` | tier3：`lispjit.c` 不在 `lispjit-ir` 真源 |
| `v45.codegen.vm_emit=1` | tier4：IR 表 Lisp 化 + emit smoke |
| `v45.release.100=1` | 仍保留 release 子键 |

## 收敛

```bash
bash lab/nano-lisp-jit/scripts/v45-wave8-converge.sh
grep v45.endgame.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

## 诚实未声称

- 仓内仍有 **其他** `.c`（`lispjit-ir` 其余 TU、`nano_*.c`）
- `run.sh` 未物理删除；v4 段仍 **skip**
- 154KB runner **全量** Lisp codegen 未达
