# v3 反思（scoped 全量签收）

**范围**：v3 切片 0–4 orchestration **100%（scoped）**；slice 4b（Lisp codegen / 零 `cc`）未达成，单独计 0%。

## 设计

- **自举两层**必须分表：A 层（用户 Lisp + self-pack）与 B 层（Lisp 出 `lispjit` slice）曾混谈，导致「v3 能自举」误解。
- `OP_CALL_FUNC` 与 AOT 参数应对齐，但 VM 函数体能力长期落后 AOT；slice1 用 compile-time infer 统一 exit 2 比散落 parse exit 3 更可测。
- aarch64 在无 cosmocc 时应用 **cross gcc + 可选 static + qemu** 证据，而不是 x86 duplicate oracle。

## 实现

- `(param i64)` 在 VM 解析里是 **元数据指令**，不能计入 label/PC 发射，否则 func 表指向 main 的 `RET`。
- `build-slice` 仍是 **stage0-bridge**（调 cc），但进入 bootstrap DSL 后，构建步骤可版本化、可审计。
- `build_nano_jit.sh` 与 `run.sh` 的 `run_case` 语义不同，需独立 `build.pass/skip/fail` 汇总。

## 测试

- 真双架构证据 = **payload hash 不同** +（可选）**qemu-aarch64-static** 对 cross slice 做 compile/run。
- v3 fixture 必须进 **self-packed** `nano-jit.com` 矩阵，不能只停在 native `lispjit` runner。

## B 层编排签收（slice 4）

- `bootstrap-v3-selfhost-gen1.lisp`：genesis runner 重建 slice + `.com` + VM smoke。
- `bootstrap-v3-selfhost-gen2.lisp`：gen1 slice runner 再跑 gen2，形成两代闭环证据。
- 门禁：`run.sh` plan + arithmetic；`build_nano_jit.sh` `selfhost-thorough-round{1,2}`。

## 下一圈（v3.5 nano-cc）

- 见 [`../v3.5/README.md`](../v3.5/README.md) 与 ROADMAP **v3.5 洋葱 TDD mindmap**。
- 第一刀：slice 0 `nano-cc` + hello.c；再 C-subset 前端 → `build-slice.role=nano-cc` → gen3 selfhost。
