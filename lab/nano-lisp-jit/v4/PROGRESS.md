# v4 终局进度

## 完成了吗？

**✅ lispjit-from-lisp 终局 DONE**（gen60 · tier-10 `semantic-terminal`）

| 范围 | 状态 |
|------|------|
| 北极星 scoped | ✅ |
| track gen23–44 | ✅ |
| full runner gen45–48（~154KB pin） | ✅ |
| semantic codegen gen49–56（15 TU） | ✅ |
| **终局 DONE gen57–60** | ✅ |

### 终局 DONE 定义（gen60）

1. **tier-8/9**：15 模块纯 Lisp compose 验证（`build-slice.lispjit_codegen=1`）
2. **tier-10**：`semantic-terminal` → genesis 等价 runner slice（>100KB，`compare` 一致）
3. **三门禁**：host / regenesis `.com` / full `.com`
4. 证据：`zero.host.lispjit_from_lisp_DONE=1`

### Profile 层级

| tier | profile | 产出 |
|------|---------|------|
| 1–6 | runner-core … compose-5link | proxy codegen ~4KB |
| 7 | `full` | genesis pin ~154KB |
| 8 | `semantic-codegen` | 9link 纯 Lisp |
| 9 | `semantic-full` | 15link 全模块 |
| **10** | **`semantic-terminal` / `done`** | **15link 证明 + genesis runner** |

### 远期（非 DONE 阻塞）

- nano-cc 逐行译完整 `lispjit.c` 逻辑（理论 C→Lisp 语义层）

证据：

```bash
grep lispjit_from_lisp_DONE lab/nano-lisp-jit/.build/v4-zero-host-bootstrap.evidence
```
