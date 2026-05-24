# v4 终局进度

## 完成了吗？

| 范围 | 状态 |
|------|------|
| **北极星 scoped（本仓库验收）** | **✅ 完成** |
| **lispjit-from-lisp track（gen23–44 门禁）** | **✅ 完成** |
| **真·100%（Lisp 源码编出完整 ~146KB lispjit slice）** | **❌ 未做** |

### scoped 完成清单

- [x] `nano-jit.com` → gen2…gen21 自举链
- [x] terminal-edge（pack-ape + JIT + pack-app）在 **gen20.com**
- [x] `zero.host.northstar_scoped_done=1`

### lispjit-from-lisp track 完成清单（gen23–44）

- [x] host / regenesis `.com` / full `.com` 上 `lispjit-from-lisp`
- [x] profile tier 1–6：`runner-core` → `linked-tu` → `multi-func` → `multi-func-cf` → `compose-3link` → **`compose-5link`**
- [x] `lispjit-modules/`：`00-runtime-core` … `03-bootstrap-stub`
- [x] `zero.host.lispjit_from_lisp_track_complete=1`（gen44 terminal + compose-5link）

### 仍未完成（诚实边界）

- [ ] Lisp 翻译 **完整 `lispjit.c`** 全 TU 图 → ~146KB runner slice（非 proxy）

### 进度尺

| 维度 | 粗估 |
|------|------|
| 自举 / 终局（scoped） | **98%** |
| **lispjit-from-lisp track 门禁** | **✅ 100%** |
| 自举（理论完整 lispjit.c codegen） | **~65%**（模块化 compose 路径已通；非完整 C 翻译） |

证据：`.build/v4-zero-host-bootstrap.evidence`

```bash
grep lispjit_from_lisp_track_complete lab/nano-lisp-jit/.build/v4-zero-host-bootstrap.evidence
```
