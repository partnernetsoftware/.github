# v4 终局进度

## 完成了吗？

| 范围 | 状态 |
|------|------|
| **北极星 scoped（本仓库验收）** | **✅ 完成** |
| **lispjit-from-lisp track（gen23–44 门禁）** | **✅ 完成** |
| **lispjit-from-lisp full runner（gen45–48，~146KB slice）** | **✅ 完成** |
| **真·语义 100%（Lisp 源码逐行译 `lispjit.c`）** | **进行中 ~78%** |

### semantic-full track（gen53–56 · tier-9）

- [x] `semantic-full` / `compose-15link`：15 TU 覆盖 `nano_*.c` 全子系统模块
- [x] 模块 `07-abi` … `12-parse`
- [x] slice 字节 ≥ compose-9link（单调增长门禁）
- [x] `zero.host.lispjit_from_lisp_semantic_full_track=1`
- [ ] slice 字节 **≥ genesis ~154KB** — 终局语义 100%

### semantic-codegen track（gen49–52 · tier-8）

- [x] `semantic-codegen` / `compose-9link`：9 TU 纯 Lisp link，`build-slice.lispjit_codegen=1`
- [x] 模块 `04-vm` / `05-aot` / `06-elf` 映射 `nano_blob_vm` / `nano_aot_x86` / `nano_elf64`
- [x] host / `.com` / full `.com` 三门禁
- [x] `zero.host.lispjit_from_lisp_semantic_track=1`
- [ ] slice 字节 **≥ genesis**（当前 ~4KB codegen vs ~154KB pin）— 终局语义 100%

### scoped 完成清单

- [x] `nano-jit.com` → gen2…gen21 自举链
- [x] terminal-edge（pack-ape + JIT + pack-app）在 **gen20.com**
- [x] `zero.host.northstar_scoped_done=1`

### lispjit-from-lisp track（gen23–44）

- [x] profile tier 1–6：`runner-core` → `linked-tu` → `multi-func` → `multi-func-cf` → `compose-3link` → **`compose-5link`**
- [x] `lispjit-modules/`：`00-runtime-core` … `03-bootstrap-stub`
- [x] `zero.host.lispjit_from_lisp_track_complete=1`

### full runner slice（gen45–48 · tier-7 `full`）

- [x] `NANO_LISPJIT_FROM_LISP_PROFILE=full` → `build-slice.role=lispjit-from-lisp-full`
- [x] slice **>100KB**，`compare` 与 `genesis/nano-jit.x86_64` 字节一致
- [x] host / regenesis `.com` / full `.com` 三门禁
- [x] `zero.host.lispjit_from_lisp_full_complete=1`

### 仍未完成（诚实边界）

- [ ] **语义层**：Lisp 逐 TU 翻译完整 `lispjit.c` 逻辑（非 pin 传播）；需 nano-cc 扩面或更大 compose 图

### 进度尺

| 维度 | 粗估 |
|------|------|
| 自举 / 终局（scoped） | **98%** |
| **lispjit-from-lisp 工程闭环（含 full slice）** | **✅ 100%** |
| 自举（C→Lisp 语义翻译） | **~78%** |

证据：`.build/v4-zero-host-bootstrap.evidence`

```bash
grep lispjit_from_lisp_full_complete lab/nano-lisp-jit/.build/v4-zero-host-bootstrap.evidence
```
