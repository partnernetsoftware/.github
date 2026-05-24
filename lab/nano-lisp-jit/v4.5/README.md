# v4.5 — 发行面 = `nano-jit.com` + `*.lisp`

**前置**：v4 lispjit-from-lisp DONE · v4 scoped catalog 闭合。

**口径**：[`DECISION.md`](DECISION.md) · v4 诚实分层：[`../v4/LISP-ONLY.md`](../v4/LISP-ONLY.md)

## 快速入口（tier0）

```bash
# 自 repo root
lab/nano-lisp-jit/.build/nano-lisp-jit run-bootstrap-plan \
  lab/nano-lisp-jit/samples/bootstrap-v45-entry.lisp

# 发行面（需 nano-jit.com）
lab/nano-lisp-jit/.build/nano-jit/nano-jit.com run-bootstrap-plan \
  lab/nano-lisp-jit/samples/bootstrap-v45-entry.lisp
```

## 文件

| 路径 | 角色 |
|------|------|
| `samples/bootstrap-v45-entry.lisp` | tier0 主入口 |
| `samples/bootstrap-v45-verify-smoke.lisp` | run.sh 前段 VM 纵切片（plan-only） |
| `samples/bootstrap-v45-entry-evidence.lisp` | 证据 rollup |
| `squad/catalog-v45.yaml` | tier0 门禁 |
| `.build/v45-entry.evidence` | `v45.entry.ok=1` |

## Tier 进度

| Tier | 状态 |
|------|------|
| 0 entry + verify-smoke | **开卷** |
| 1 plan-only CI | 未开 |
| 2 无 host cc | 未开 |
| 3 无 C 源码 | 未开 |
| 4 VM emit | 未开 |
