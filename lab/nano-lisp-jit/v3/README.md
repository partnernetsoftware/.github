# nano-lisp-jit v3 kickoff

v2.5 **100%（scoped）** 完成。v3 从 v2.5 反思出发，见 [`../ROADMAP.md`](../ROADMAP.md)（`### v3 完成度`、mindmap 节点 `v2.5 反思 · 汇入 v3` 与 `v3+`）。

## v3 完成度

| 切片 | 状态 | 说明 |
|------|------|------|
| slice 0 VM `OP_CALL_FUNC` | **0%** | 真 `(func …)` + `(call …)`；`func-call-smoke.lisp` + `run.sh` |
| slice 1 错误码/arity | **0%** | VM/AOT 负向统一错误码 |
| slice 2 aarch64 native slice | **0%** | 真 aarch64 payload，非 x86 duplicate oracle |
| slice 3 证据/bootstrap | **0%** | bootstrap 覆盖 `NANO_PACK_APE_MODE` + skip 统计 |

**v3 整体**：**0%** — ROADMAP 表与本文同步更新。

## v3 优先级（洋葱序）

1. **VM `OP_CALL_FUNC`** — 真 `(func …)` + `(call …)`，对齐 AOT 参数/返回值模型
2. **错误码/arity** — VM/AOT 负向统一
3. **aarch64 native slice** — 替代 x86 duplicate oracle
4. **证据** — bootstrap DSL + skip 统计 + 可选 bare pack 默认

## 命令

```bash
bash lab/nano-lisp-jit/run.sh
```
