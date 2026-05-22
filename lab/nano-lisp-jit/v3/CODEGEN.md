# v3 slice 4b — Lisp / nano-cc codegen

v3 **完全 100%** 的定义包含本文件三级；**v3.5 在 v3 完全 100% 前不启动**（见 [`../v3.5/README.md`](../v3.5/README.md)）。

## 三级

| 级别 | 含义 | 状态 |
|------|------|------|
| **4b-1** | `build-slice-lisp`：`.lisp` → ELF（`compile-elf64-code`，零 host `cc`） | 实现 + 门禁 |
| **4b-2** | `build-slice` + `nano-cc-hello.c`：`nano-cc` C-subset → ELF | 实现 + 门禁 |
| **4b-3** | `build-slice` 编全量 `lispjit.c` 零 host `cc` | **未达成** — v3 完全 100% 阻塞项 |

**v3 完全 100%** = slice 0–3 + slice 4 编排 + **4b-1 + 4b-2 + 4b-3** 全部签收。

**v3 当前（工程表）**：编排 100%；codegen **4b-1/4b-2 进行中**，4b-3 待办。

## 证据

```bash
bash lab/nano-lisp-jit/run.sh   # run-bootstrap-v3-build-slice-lisp-plan, codegen-smoke, gen3
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

样例：

- `samples/bootstrap-v3-build-slice-lisp.lisp`
- `samples/bootstrap-v3-codegen-smoke.lisp`
- `samples/bootstrap-v3-selfhost-gen3.lisp`

日志关键字：`build-slice.role=lisp-codegen`，`build-slice.compiler=nano-jit-lisp` 或 `nano-cc`。
