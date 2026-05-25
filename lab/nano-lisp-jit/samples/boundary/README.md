# boundary samples

探索 `nano-jit.com` VM/AOT 能力边界的 **纯 `.lisp`** 样例（无 `.c`）。

| plan | 用途 |
|------|------|
| `bootstrap-v45-boundary-probe.lisp` | 正向：compile + run + 部分 AOT exit |
| `bootstrap-v45-boundary-negative.lisp` | 负向：`compile-expect-exit 2` |

验收：`.com run-bootstrap-plan`（repo root）；工厂落盘见 `run.sh` `run-bootstrap-v45-boundary-*`。

## 正向样例

| 样例 | 探测点 |
|------|--------|
| `add-i64-chain.lisp` | i64 加减链 |
| `cmp-i64-ops.lisp` | eq/lt/gt/ne |
| `i64-mul-chain.lisp` | mul-i64 + eq |
| `nested-func-call.lisp` | 嵌套本地调用 |
| `func-param-chain.lisp` | param + load-arg + 多级 call |
| `branch-merge.lisp` | block + branch |
| `multi-func-call.lisp` | 多函数 call（VM + AOT exit 43） |
| `store-load-u8.lisp` | const-ptr + load-u8 |
| `load-u16-rodata.lisp` | const-ptr + load-u16 |
| `ptr-null-arith.lisp` | null/add/sub/ptr-to-u64 |

## 负向（plan 引用 `samples/*-bad.lisp`）

| 探测 | 预期 |
|------|------|
| `func-param-missing-param-bad` | VM `compile` exit 2 |
| `func-param-call-no-arg-bad` | VM `compile` exit 2 |
| `type-error-load-u8-bad` | AOT `compile-elf64-exe` exit 2 |
| `type-error-ptr-op-bad` | AOT `compile-elf64-exe` exit 2 |

## 已知未支持（勿写入正向样例）

- `store-load-u32` / 宽于 VM 的 load-u32 日常路径
- 无 param 的 `load-arg-i64`
