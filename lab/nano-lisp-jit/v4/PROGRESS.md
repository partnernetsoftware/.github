# v4 终局进度

## 完成了吗？

| 范围 | 状态 |
|------|------|
| **北极星 scoped（本仓库验收）** | **✅ 完成** |
| **真·100%（Lisp 源码编出完整 lispjit）** | **❌ 未做**（gen30–31 为 partial northstar；非完整 lispjit.c codegen） |

### scoped 完成清单

- [x] `nano-jit.com` → gen2…gen21 自举链
- [x] terminal-edge（pack-ape + JIT + pack-app）在 **gen20.com**
- [x] `selfhost-reuse` 在 **.com runner**（gen19→gen20）
- [x] `NANO_REGENESIS=1` 传播新 runner
- [x] 纯 Lisp plan 产出 `.com`（**gen22**，无 `lispjit.c`）
- [x] `zero.host.northstar_scoped_done=1`
- [ ] 真·Lisp 编出完整 `lispjit.c`（当前仅 runner-core 代理 profile）
- [x] gen23 门禁：`NANO_LISPJIT_FROM_LISP=1` + `build-slice.role=lispjit-from-lisp`
- [x] gen24/26：`nano-jit.com`（regenesis repack）上零 host `lispjit.c` slice
- [x] gen27：`lispjit-from-lisp` + pack-app 终端 smoke
- [x] gen28：`NANO_LISPJIT_FROM_LISP_PROFILE=linked-tu` 多 TU link
- [x] gen29：lispjit-from-lisp slice → selfhost-reuse → chain `.com`
- [x] gen30：regenesis 完整 `.com` 上跑 `lispjit-from-lisp`（`lispjit_from_lisp_on_full_com`）
- [x] gen31：linked-tu + pack-app partial northstar 门禁
- [x] gen32/33：完整 `.com` 上 linked-tu 终端 + `ir-exit-v1` tier-2 profile
- [x] gen34/35：tier-3 **multi-func AOT**（真实 func call codegen，exit 43）
- [x] gen36–38：tier-4 **multi-func-cf**（控制流/i64 AOT + slice→reuse 链）
- [x] gen39–41：tier-5 **compose-3link** + `lispjit-modules/` 子模块路径
- [x] lispjit-from-lisp track 汇总门禁（`lispjit_from_lisp_track_gates`）
- [ ] 完整 Lisp 编出 `lispjit.c` 本体（非 proxy profile）

### 进度尺

| 维度 | 粗估 |
|------|------|
| 自举 / 终局（scoped） | **98%** |
| 自举（理论 lispjit-from-lisp） | **~55%**（tier-5 三 TU link + `lispjit-modules/`；仍非完整 `lispjit.c`） |

证据：`.build/v4-zero-host-bootstrap.evidence`

```bash
grep northstar_scoped_done lab/nano-lisp-jit/.build/v4-zero-host-bootstrap.evidence
```
