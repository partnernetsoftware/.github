# cross-arch-ffi

目标：探索“体积小、跨架构可执行、动态执行、可 FFI 调系统库”的综合方案。

## 结论先行

最有价值的结构不是单一路线，而是分层：

1. **最小核心**：FFI resolver + 可执行内存 + 每架构 JIT call stub。
2. **动态执行层**：micro-JIT 负责短路径，TCC 负责动态 C 编译。
3. **跨架构分发层**：Cosmopolitan APE 或 per-arch bundle。

当前实测最关键数字：x86_64 上，JIT payload **23 字节**即可调用 FFI 解析到的系统 `strlen`。

## 文件定位

- `strategy.md`：完整方案分层、取舍和推荐架构。
- `matrix.md`：候选路线对比。
- `ffi_probe.c`：验证系统库 FFI。
- `byte_budget.c`：验证“FFI + JIT 合体”的最小机器码路径。
- `run.sh`：证据生成脚本，不是最终 runtime；它只用来复现体积和能力数据。

## 复现实测

```bash
cd /workspace
bash lab/cross-arch-ffi/run.sh
```

`run.sh` 会输出：

- 可用 runtime 的体积清单。
- native C、TCC、CosmoRun 的 FFI 验证结果。
- `byte_budget.c` 的 JIT payload 字节数和调用结果。

若当前 checkout 缺少 TCC 链接所需 CRT 对象，脚本会记录失败并降级为 `-c` 编译对象验证。
