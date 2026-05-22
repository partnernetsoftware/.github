# v3 反思（scoped core 签收）

**范围**：v3 切片 0–3 视为 **100%（scoped）**；切片 4（Lisp 编编译器 / B 层）仍在进行（~40%），不计入本次签收。

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

## 下一圈（v3+ / slice 4）

- Lisp/IR  lowering 产出 slice 字节，去掉对 `lispjit.c` 的 stage0 `cc`。
- 固定 seed 后，self-packed runner 执行完整构建图生成下一代 `.com`。
