# v4 — 终局切片 + 产品轨

**前置**：v3.5-scoped + v3.5-terminal 已签收（见 [`../v3.5/DECISION.md`](../v3.5/DECISION.md)）。

## 范围（首波）

| 轨 | 目标 | 非目标（本波） |
|----|------|----------------|
| **slice** | aarch64 VM/AOT 真 codegen（非 add-emit 硬编码） | 全量 `lispjit.c` 单 TU 替换 |
| **编排** | bootstrap 内 squad 状态机草图（替代 host Python） | 完整分布式多机 |
| **产品** | NDTSV / SQL / qjs 探路文档 | 生产级产品 |

## 小队

```bash
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml resume
tools/squad/squad.sh --catalog lab/nano-lisp-jit/squad/catalog-v4.yaml agent-team
```

## 证据

- `run.sh` / `build_nano_jit.sh` 不退化
- 新样本只增 `samples/bootstrap-v4-*.lisp`
