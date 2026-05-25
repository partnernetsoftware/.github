# v4.5 终局进度

## scoped 100%？

**✅ v4.5 scoped 100%**（洋葱 TDD · 仅 `.com` + `*.lisp` 验收）

| Tier | 状态 | 证据键 |
|------|------|--------|
| 0 entry | ✅ | `v45.entry.ok=1` |
| 1 com-only verify | ✅ | `v45.verify.plan_only=1` |
| 2 genesis build-slice | ✅ | `v45.build.no_host_cc=1` |
| onion TDD | ✅ | `v45.onion.lisp_only=1` |
| boundary 探测 | ✅ | `v45.boundary.probes=10` · `v45.boundary.negative=1` |
| 目录清理 | ✅ | `v45.cleanup.ok=1` |
| **scoped DONE** | ✅ | **`v45.scoped.100=1`** |

### scoped 100% 定义

1. `nano-jit.com` 可跑完整 verify 矩阵 + `onion-tdd` + boundary 正/负向
2. `build-slice` 日常路径为 **genesis-pin**（`env -u` selfhost reuse）
3. 洋葱验收 **不依赖** plan 内调用 `.sh`；`run.sh` 仅工厂落盘
4. v4 子轨 lispjit-from-lisp **保持 DONE**（handoff plan 锚定）

### 「完全 100%」诚实未声称

| 项 | 状态 |
|----|------|
| repo 零 `.c` / `.py` / `.sh` | 未达（tier3–4） |
| `run.sh` 1212 case 退役 | 未达 |
| Lisp 全量 codegen 154KB runner | 未达（genesis pin） |
| VM emit 替代 C 表 | 未达（tier4） |

证据：

```bash
grep v45.scoped.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```
