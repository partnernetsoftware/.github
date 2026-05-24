# v4 终局进度

## 完成了吗？

| 范围 | 状态 |
|------|------|
| **北极星 scoped（本仓库验收）** | **✅ 完成** |
| **真·100%（Lisp 源码编出完整 lispjit）** | **❌ 未做**（超出当前 slice/reuse 能力） |

### scoped 完成清单

- [x] `nano-jit.com` → gen2…gen21 自举链
- [x] terminal-edge（pack-ape + JIT + pack-app）在 **gen20.com**
- [x] `selfhost-reuse` 在 **.com runner**（gen19→gen20）
- [x] `NANO_REGENESIS=1` 传播新 runner
- [x] 纯 Lisp plan 产出 `.com`（**gen22**，无 `lispjit.c`）
- [x] `zero.host.northstar_scoped_done=1`

### 进度尺

| 维度 | 粗估 |
|------|------|
| 自举 / 终局（scoped） | **98%** |
| 自举（理论 lispjit-from-lisp） | **0%**（未开卷） |

证据：`.build/v4-zero-host-bootstrap.evidence`

```bash
grep northstar_scoped_done lab/nano-lisp-jit/.build/v4-zero-host-bootstrap.evidence
```
