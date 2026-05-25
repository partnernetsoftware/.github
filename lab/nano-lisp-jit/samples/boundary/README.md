# boundary samples

探索 `nano-jit.com` VM/AOT 能力边界的 **纯 `.lisp`** 样例（无 `.c`）。

验收：`bootstrap-v45-boundary-probe.lisp`（由 `.com run-bootstrap-plan` 驱动）。

| 样例 | 探测点 |
|------|--------|
| `add-i64-chain.lisp` | i64 算术链 |
| `cmp-i64-ops.lisp` | 比较运算 |
| `nested-func-call.lisp` | 嵌套本地调用 |
| `store-load-u8.lisp` | const-ptr + load-u8 |
| `branch-merge.lisp` | 分支汇合 |
