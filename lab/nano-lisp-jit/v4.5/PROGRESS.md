# v4.5 终局进度

## 发行面 100% ✅

**签收键**：`v45.release.100=1` · `v45.scoped.100=1`

| 维度 | 状态 | 证据 |
|------|------|------|
| scoped 洋葱 TDD | ✅ | `v45.onion.lisp_only=1` · `v45.onion.primary_lisp_only=1` |
| com-only verify | ✅ | `v45.verify.plan_only=1` |
| genesis build-slice | ✅ | `v45.build.no_host_cc=1` |
| 自举 S2–S5 | ✅ | `v45.selfhost.*` |
| boundary + 反馈 | ✅ | `v45.boundary.probes=13` · `v45.product.feedback=1` |
| 单轮收敛 | ✅ | `v45-wave7-converge.sh` |
| scoped CI | ✅ | `tests.pass=2` in `v45-scoped-results.txt` |
| 工厂 v4 skip | ✅ | `NANO_V45_SCOPED_ONLY=1` + `v45.factory.v4_skipped=1` |
| **release DONE** | ✅ | **`v45.release.100=1`** |

### 发行面 100% 定义

1. 全部 `bootstrap-v45-*.lisp` 由 `v45-wave7-converge.sh` 跑绿
2. 主洋葱 = `onion-lisp-only`（plan 内无 `lispjit.c` build-slice）
3. `terminal-done` / `endgame-100` 证据 rollup 绿
4. 工厂可 `NANO_V45_SCOPED_ONLY=1` 跳过 v4 `run_case` 墙（不删 `run.sh` 文件）

## 全仓终局（诚实未达）

| Tier | 状态 | 键 |
|------|------|-----|
| T3 删 `lispjit.c` | ❌ | `v45.runner.no_c_src=0` |
| T4 VM emit | ❌ | `v45.codegen.vm_emit=0` |
| 零 `.sh` 工厂 | ❌ | `run.sh` 仍存在；v4 段仅 skip |

## Wave 扩散

| Wave | 状态 |
|------|------|
| Wave3–6 | ✅ 见 `DIFFUSE-WAVE3.md` … `DIFFUSE-WAVE6.md` |
| **Wave7** | ✅ [`DIFFUSE-WAVE7.md`](DIFFUSE-WAVE7.md) — **release 100%** |

## 证据

```bash
bash lab/nano-lisp-jit/scripts/v45-wave7-converge.sh
grep -E 'v45\.(release\.100|scoped\.100)=' lab/nano-lisp-jit/.build/v45-entry.evidence
```
