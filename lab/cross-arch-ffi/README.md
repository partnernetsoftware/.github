# cross-arch-ffi

目标：在 `lab/` 下验证“小体积 + 跨架构 + 能 FFI 调系统库”的可执行程序路线。

## 快速运行

```bash
cd /workspace
bash lab/cross-arch-ffi/run.sh
```

`run.sh` 会用同一个 `ffi_probe.c` 测三条路线：

- `native-cc`：最小原生动态链接基线。
- `bundled-tcc`：仓库内 `third_party/tccx.sh`，验证 per-arch TinyCC。
- `cosmorun`：仓库内 `cosmorun/cosmorun.exe`，验证源码直接运行和系统库 FFI。

探针会实际执行：

- `dlopen`/`dlsym` 打开 libc 并调用 `puts`。
- `dlopen`/`dlsym` 打开 libm 并调用 `cos(0)`。
- 输出当前 OS、架构、二进制体积。

## 当前判断

首选主线：`CosmoRun + TinyCC`。它牺牲一部分 runtime 体积，换来跨平台单入口、C ABI、系统库 FFI 和运行时代码能力。

最小基线：原生 C/TCC per-arch。它体积最小，但需要每个架构各自分发。

Lua 5.4 标准版不自带 FFI；如果继续走 Lua，需要 C bridge，或单独评估 LuaJIT。

详细对比见 `matrix.md`。
