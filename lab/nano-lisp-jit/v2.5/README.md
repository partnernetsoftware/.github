# nano-lisp-jit v2.5 — v2 retrospective hardening

v2 **100%（scoped）** 已签收；v2.5 把反思缺口变成可测切片。Mindmap：`../ROADMAP.md` → `v2.5: v2 反思收口`。

## 进度（~85%）

| 切片 | 状态 |
|------|------|
| 反思 mindmap | 100% |
| slice 0 证据门禁 | 100% |
| slice 1 x86-only self-pack oracle | 100% |
| slice 2 `nano_util` | 100% |
| slice 2b `nano_types.h` | 100% |
| TU 探针 `verify_tu.sh` | 100% |
| slice 3 AOT 参数 | ~80%：单/双 `(param i64)`、`save-top-i64`、负向 fixture |
| VM 多函数参数 | 0%（v3） |

## AOT 双参调用约定

```lisp
(i64 41)          ; → rdi（经 save）
(save-top-i64)
(i64 1)           ; → rsi
(call callee-2arg)
```

## 证据

```bash
bash lab/nano-lisp-jit/run.sh
NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```
