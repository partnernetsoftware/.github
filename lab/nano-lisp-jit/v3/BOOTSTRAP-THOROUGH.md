# v3 自举彻底（scoped）定义

## 三层

| 层 | 含义 | 签收标准 |
|----|------|----------|
| **Genesis** | 一次性 host `cc` 产出 `nano-jit.x86_64` seed | 行业惯例的固定种子；非每圈重建 |
| **Orchestration** | 构建图全在 Lisp `bootstrap` DSL | `bootstrap-v3-selfhost-gen{1,2}.lisp` |
| **Codegen** | Lisp 生成 slice 机器码，零 `cc` | **未达成** — `build-slice` 仍调 `cc` |

**自举彻底（scoped）** = Genesis + Orchestration 闭环证据，不要求 Codegen。

## 闭环证据

1. **Gen1**：seed runner 执行 `bootstrap-v3-selfhost-gen1.lisp` → `gen1-slice-x86.elf` + `gen1-nano-jit.com` + smoke `.lbin`
2. **Gen2**：gen1 slice runner 再执行 `bootstrap-v3-selfhost-gen2.lisp` → gen2 产物 + arithmetic run
3. **门禁**：`build_nano_jit.sh` `selfhost-thorough-*` + `run.sh` plan 解析

## 命令

```bash
# 在已有 genesis seed 后（build_nano_jit 会先 cc 出 x86_64）：
env NANO_SELFHOST_THOROUGH=1 NANO_SLICE_COMPILER=native bash lab/nano-lisp-jit/build_nano_jit.sh
```

## 与 A 层区别

- **A 层**：用户 `.lisp` → `.lbin`；`pack-ape` 不调用 apelink
- **B 层（本文件）**：**编译器重建编排**在 Lisp；slice 源码仍为 `lispjit.c` + 外部 `cc`
