# v3 slice 4b — Lisp / nano-cc / genesis-pin codegen

v3 **完全 100%** = slice 0–3 + slice 4 编排 + **4b-1 + 4b-2 + 4b-3**。  
**v3.5 已启动**（slice 0 100%；切片 1–6 并行）— 见 [`../v3.5/README.md`](../v3.5/README.md)、[`../v3.5/PARALLEL.md`](../v3.5/PARALLEL.md)。  
v3 完全 100% **不再阻塞** v3.5（4b-3 genesis-pin 已签收）。

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

## v3.5 扩展（并行）

| 目标 | 当前（4b / slice 0） | v3.5 终态 |
|------|----------------------|-----------|
| `lispjit.c` slice | genesis-pin 复制 | slice 3：`build-slice.role=nano-cc` |
| C 输入 | `nano-cc-hello.c` only | slice 1：`add-parse` + 扩 TU |
| aarch64 | genesis-pin / cross cc | slice 4：nano-cc 发射或路线 B |

日常路径在 slice 3 签收前**保持 genesis-pin**；并行轨道见 [`../v3.5/PARALLEL.md`](../v3.5/PARALLEL.md)。错误码：[`../v3.5/ERROR-CODES.md`](../v3.5/ERROR-CODES.md)。
