# v3 slice 4b — Lisp / nano-cc / genesis-pin codegen

v3 **完全 100%** = slice 0–3 + slice 4 编排 + **4b-1 + 4b-2 + 4b-3**。  
**v3.5 在 v3 完全 100% 前不启动**（见 [`../v3.5/README.md`](../v3.5/README.md)）。

## 三级

| 级别 | 含义 | 状态 |
|------|------|------|
| **4b-1** | `build-slice-lisp`：`.lisp` → ELF（`compile-elf64-code`，零 host `cc`） | **100%** |
| **4b-2** | `nano-cc` + `nano-cc-hello.c` | **100%** |
| **4b-3** | `build-slice` + `lispjit.c`：日常零 host `cc`（`genesis-pin`） | **100%** |

### 4b-3 语义

- 日常：`(build-slice "…/lispjit.c" …)` → `build-slice.role=genesis-pin`，从 [`../genesis/`](../genesis/) 复制已 pin 的 slice ELF。
- 刷新 genesis（有意使用 host `cc` / cross-gcc）：

```bash
env NANO_REGENESIS=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

- 临时回退 host `cc`：`NANO_SLICE_ALLOW_HOST_CC=1`。

Genesis 与编排层关系：[`BOOTSTRAP-THOROUGH.md`](BOOTSTRAP-THOROUGH.md)。

## 证据

```bash
bash lab/nano-lisp-jit/run.sh
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

日志：`build-slice.role=genesis-pin`（`lispjit.c`）；`lisp-codegen`（`build-slice-lisp` / `nano-cc`）。
