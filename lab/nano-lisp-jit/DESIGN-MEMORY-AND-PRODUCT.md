# 内存安全借鉴与产品化命名

本文档记录从 Rust 内存管理哲学可对 `nano-lisp-jit` / `nano-jit` 借鉴的改进方向，以及工具链产品化命名建议。供路线图与实现分身对齐，**不要求照搬 Rust borrow checker**。

## 原则

- 保持：极小 DSL、`.lbin` 可 inspect、洋葱 TDD、AI 友好错误信息。
- 借鉴 Rust 的核心不是 GC，而是 **编译期可证明的不变量**（类型、别名、段权限、生命周期边界）。
- 与现有资产对齐：typed `i64` / `bool` / `ptr`、`expect`、`compile-expect-exit` 负向样例、v1.5 `.rodata/.data`、v2 局部变量/SSA。

## 从 Rust 可借鉴的改进（按优先级）

### P0 — 与 v1.5 / v2 路线图直接重合

| 方向 | Rust 对应 | nano 建议 | 路线图挂钩 |
|------|-----------|-----------|------------|
| 不可变默认 | 默认不可变，`mut` 才写 | `const-ptr` 只读；可写数据进 `.data`；DSL 区分 `ptr-ro` / `ptr-mut`，编译期禁止对 ro 做 `store-*` | v1.5 `.rodata/.data` |
| 段权限分离 | `const` / static 布局 | 移除 text 内嵌数据的 RWX 策略；只读 const 与可写 data 分 section | v1.5 data section |
| 显式错误语义 | `Result` / `panic!` | 除 `(expect N)` 外增加 `(ret-err code)` 或 typed 错误链，区分断言失败与业务错误 | v2 richer IR |

### P1 — 轻量内存契约（不引入完整 borrow checker）

| 方向 | Rust 对应 | nano 建议 | 验收方式 |
|------|-----------|-----------|----------|
| 非空指针类型 | `NonNull` / `Option` | IR 层 `ptr!`（非空）vs `ptr?`；`const-ptr sym` 编译期绑定符号 | 负向样例 + `compile-expect-exit` |
| 轻量 region | 生命周期参数（简化） | `const-ptr` 带 region：`func` / `object` / `link`；AOT 校验 load/store 不越 region | cross-object smoke 扩展 |
| 移动 vs 复制 | `Copy` / `Move` | 弃用纯「上一条栈顶值」语义，改为 slot / `move-ptr` / `copy-ptr`（与 v2 局部变量一并做） | VM 与 codegen 对照 fixture |
| 别名规则 | 可变与不可变不别名 | 纯 VM 静态 def-use：`store` 后旧 `ptr` slot 不可再 `load`；debug 模式 `run-borrow-check` | native + bootstrap DSL |
| 边界与对齐 | 切片 + layout | 保留 `store` 立即数范围检查；增加对齐断言；链接期校验 PC32/RIP 跨 section | 负向 relocation 样例 |

### P2 — FFI 与运行时边界

| 方向 | Rust 对应 | nano 建议 |
|------|-----------|-----------|
| RAII / 资源域 | `Drop` | `with-libc { ... }` 块：resolve/open 与成对 teardown（可先文档化，再 codegen） |
| 并发边界 | `Send` / `Sync` | 文档：`.lbin` VM 单线程；APE payload 只读共享；import 表可选 `thread-safe` 标记 |
| 证明型测试 | Miri 思路 | CLI `run-borrow-check`：解释执行跟踪 ptr 来源，与 AOT 结果对照 |

### 明确不做（v2 之前）

- 完整过程间 borrow checker（与「极小、可 inspect」冲突）。
- 隐式 GC 作为默认内存模型（与 AOT/确定性 blob 目标不一致）。
- 为借鉴 Rust 而扩大 DSL 语法表面到难以自举验证。

## 建议纳入 ROADMAP 的切片（记忆契约 track）

```text
memory-contract track (可并行 v1.5 / v2)
├─ slice A: ptr-ro / ptr-mut 类型 + 负向 store 样例
├─ slice B: region 标注 + cross-object 越界拒绝
├─ slice C: slot 模型替代栈顶值（配合 v2 局部变量）
├─ slice D: run-borrow-check 解释器模式（debug）
└─ slice E: ret-err / Result 风格 IR（产品化错误码）
```

## 产品化命名

### 推荐层次

| 层级 | 名称 | 用途 |
|------|------|------|
| 工具链总品牌 | **NanoJIT** | CLI、文档、仓库对外名；二进制 `nano-jit.com` |
| 可移植 IR 产物 | **Lbin** | `.lbin` 格式；强调「只分发 blob、不需源码」 |
| 多架构发行物 | **Nano APE** | `.com` 容器；x86_64 / aarch64 payload table |
| 构建描述（内部） | **Bootstrap DSL** | `(bootstrap …)` 计划；可先不作为对外子品牌 |

### 备选对外名

| 名称 | 优点 | 适用 |
|------|------|------|
| **Nanape** | 突出 APE + nano | 发行、单文件工具 |
| **Lbin** | 格式即品牌 | SDK、包管理 |
| **APEL** | APE + Lisp 缩写 | 运行时叙事 |

### 不推荐作为主品牌

- `nano-lisp-jit` — 偏仓库/实验路径名，过长。
- `Oxide*` / `Rust*` 系 — 易误解为 Rust 实现或 fork。

### 对外一句话

> **NanoJIT**：用 Lisp-like 模块编写逻辑，编译为确定性 **Lbin**，经 JIT/AOT 与 **Nano APE** 在多架构上运行。

### CLI 命名一致性（产品化时）

```text
nanojit compile  …   # 或保留 nano-jit.com 单文件 APE 入口
nanojit run      …   # .lbin
nanojit pack     …   # .com / APE
```

实现阶段可继续用 `nano-jit.com` 子命令，文档与 README 统一称 **NanoJIT**。

## 与消费者文档的关系

- 集成摩擦：`LAB-USAGE-FEEDBACK.md`
- 版本切片：`ROADMAP.md`
- 本文档：跨版本的设计意向，**不替代** ROADMAP 中的验收标准

## 变更记录

| 日期 | 说明 |
|------|------|
| 2026-05-21 | 初稿：Rust 借鉴清单 + NanoJIT/Lbin/Nano APE 命名层次 |
