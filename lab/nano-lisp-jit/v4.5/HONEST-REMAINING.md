# 物理终局 — 诚实口径（Wave15 更新）

> **tier5 发行面 100%**：`v45.tier5.100=1` · `v45.honest.tier5.open=0`  
> **发行面树零真 `.c`**：`v45.physical.zero_c=1`（`lispjit-ir` + `samples/` 仅 symlink；真源在 `archive/`）

## 证据键

| 键 | 含义 |
|----|------|
| `v45.tier5.100=1` | T5a–T5d 齐（见 [`DIFFUSE-WAVE15.md`](DIFFUSE-WAVE15.md)） |
| `v45.physical.zero_c=1` | **发行面树** 无真 `.c`（非全 monorepo） |
| `v45.physical.archive_runner_c_files=N` | 工厂 `archive/runner` 真源（透明） |
| `v45.physical.archive_fixtures_c_files=M` | `archive/fixtures` 真源 |

## 仍未声称

- 全仓库（如 `lab/cross-arch-ffi`）零 `.c`
- 154KB runner **全量** Lisp codegen 替代 C
- 物理删除 `run.sh`

## 日常

```bash
bash lab/nano-lisp-jit/scripts/v45-wave15-tier5-100-converge.sh
```

全量 v4 工厂：`NANO_V45_FULL_FACTORY=1 bash lab/nano-lisp-jit/run.sh`
