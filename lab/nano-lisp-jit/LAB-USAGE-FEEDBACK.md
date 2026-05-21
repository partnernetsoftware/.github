# lab 消费者使用反馈

由 `lab/tool-*` 等子项目在调用 `nano-lisp-jit` 时发现的问题与建议，供后续会话修复本体。

更新：2026-05-21（lab 消费者脚手架首次落地）

## 已验证可用

- 从任意路径调用 `compile` / `run` / `compare` / `hash` / `compile-elf64-code` / `run-expect-exit`（需 x86_64 host）。
- 消费者通过 `lab/_nano_common.sh` 定位 `lab/nano-lisp-jit/.build/nano-lisp-jit`；若缺失可触发 `run.sh` 构建。
- `lab/run-lab-tools.sh` 聚合：`tool-exit42`、`tool-strlen-check`、`tool-blob-compare`、`tool-resolve-check`。

## 路线响应

- 这些反馈已进入 `ROADMAP.md` 的 `v1.5 slice 0: consumer feedback closure`。
- v1.5 开工顺序调整为：先跑 `bash lab/run-lab-tools.sh`，收敛 CLI/DSL 命名、runner 定位、repo-root 路径、`run` 退出码语义和 x86_64 限制说明，再进入 nano APE manifest。
- README 已补充消费者集成注意事项；后续若选择实现 CLI alias 或新子命令，应在对应问题条目下标注 commit/PR。

## 问题 1：`resolve-quiet` 仅存在于 bootstrap DSL，不是顶层 CLI 子命令

**现象**：`nano-lisp-jit resolve-quiet foo.lbin` 会打印完整 `usage` 并以失败退出（exit 2）。

**期望**：README/bootstrap 样例里 `(resolve-quiet …)` 容易让人以为 CLI 也有同名子命令。

**实际**：独立 CLI 为 `resolve --quiet program.lbin`。

**建议**：

- 在 `README.md` CLI 一节明确写：`resolve-quiet` 仅用于 `(bootstrap …)`；命令行用 `resolve --quiet`。
- 或增加 `resolve-quiet` 作为 `resolve --quiet` 的别名，减少 DSL/CLI 分裂。

**消费者规避**：`lab/tool-resolve-check/build.sh` 使用 `resolve --quiet`。

## 问题 2：无安装路径 / 无 `NANO_JIT` 环境变量约定

**现象**：外部项目必须硬编码 `lab/nano-lisp-jit/.build/nano-lisp-jit` 或自行 `cc -DNANO_LISP_JIT lispjit.c`。

**建议**：文档增加「消费者集成」小节：`NANO_JIT` 或 `../../nano-lisp-jit/.build/...` 约定；可选 `make install` 到 `$(prefix)/bin`。

## 问题 3：bootstrap DSL 路径假定仓库根目录

**现象**：`samples/bootstrap-*.lisp` 与 `run-bootstrap-plan` 内路径多为 `lab/nano-lisp-jit/...`，从 `lab/tool-*/` 写 bootstrap 计划时需手写 repo-root 相对路径。

**建议**：支持 `NANO_REPO_ROOT` 或 bootstrap 内 `(root "…")` 前缀；或在 README 注明必须从 repo root 执行 `run-bootstrap-plan`。

## 问题 4：`run` 的进程退出码等于程序返回值

**现象**：若 `.lbin` 以 `(call getpid)` 结束且无 `expect`，`run` 会以 pid 作为 shell 退出码（通常非 0），`set -e` 的 shell 脚本会误判失败。

**建议**：文档说明「调试 FFI 返回值」与「自测成功」的区别；或提供 `run-expect-success`（只断言 VM 未报错、不断言退出码）。

**消费者规避**：lab 工具用 `(expect N)` 固定断言，避免把 pid 当成功退出码。

## 问题 5：AOT / `compile-elf64-*` 仅 x86_64 Linux

**现象**：`lab/tool-exit42` 依赖 `compile-elf64-code`；非 x86_64 host 需跳过（与 `run.sh` 一致）。

**建议**：CLI 在非 x86_64 上给出明确 `skip: host is not x86_64` 而非 `compile_fail`。

## 未发现问题（本轮）

- 绝对路径 `.lisp` / 输出路径：可正常读写。
- 首次构建触发完整 `run.sh` 较慢；可考虑 `nano_runner` 只 `cc` 单二进制（后续优化）。

---

修复任一问题后，请在本文件对应条目注明 commit/PR，并跑 `bash lab/run-lab-tools.sh` 复验。
