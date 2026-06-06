# nano-lisp 会话 handoff

**更新**: 2026-06-06 · **cursor/nanolisp-gate-build-dir-ee28** · **c-gate 全绿** · terminal daily

## 北极星

用户 daily 只依赖 **`release/nano-lisp.com`** + **`*.lisp`**（plan + dogfood）。工厂（cosmocc/host-cc/`.sh`）开卷，不算 user path。

## 两轨 SSOT（勿混称 100%）

| 轨 | 目标 | 状态 |
|----|------|------|
| **A — 用 pin 跑 dogfood** | shell/com daily，plan 内无 `.sh`/`.c`/Rust | ✅ **100%** |
| **B — 从 lisp 重造 runner** | 158KB slice 纯 codegen | ✅ **~100%**（含 flat bundle） |
| **B′ — 全 COM 自举** | 863KB 全 runner 无 cosmocc | ❌ **0%** |

文档 SSOT：
- A：`lab/nano-lisp-jit/v4.5/COM-LISP-ONLY.md`
- B 工厂矩阵：`lab/nano-lisp-jit/v4.5/HONEST-REMAINING.md`
- rollup：`lab/nano-lisp-jit/v4.5/OVERALL-PROGRESS.md`

## Release pin（当前）

```
nano-lisp.com.bytes=871193
nano-lisp.com.fnv1a64=eb502ddb9aa426c1
```

含：`run-stdin` · `build-slice-lisp-profile` · `(lisp-root ".")` · shell rodata embed

重打 pin：`bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-shell-release-promote.sh`（需 cosmocc @ `third_party/cosmocc/bin`）

## Bootstrap DSL（COM 内，plan 可用）

| 步骤 | 用途 |
|------|------|
| `(run-stdin "text\n" "path.lbin")` | fork+pipe，无 `/bin/sh` |
| `(build-slice-lisp-profile "compose-15link-semantic-unified" "lisp/lispjit.c" "out.elf" "x86_64")` | 158KB codegen，profile 在 plan |
| `(lisp-root ".")` | 设 `NANO_LISP_ROOT`；`.`= flat bundle，省略= `lab/nano-lisp-jit` |

compose15 模块路径：`lisp/modules-semantic/…`，经 `nano_lisp_join(root, rel)` 解析（`nano_bootstrap.c`）。

## Daily plans

### TERMINAL — one plan (A+B+B′)

```bash
COM=lab/nano-lisp-jit/release/nano-lisp.com
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-daily-terminal.lisp
```

产出：dogfood · 158KB codegen · pure-lisp pack (~161KB) · **871KB regenesis.com** · child spawn

### A 轨 — dogfood

```bash
COM=lab/nano-lisp-jit/release/nano-lisp.com

# repo 树
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-com-lisp-only-daily.lisp

# flat bundle
./nano-lisp.com run-bootstrap-plan bootstrap/bootstrap-v45-com-lisp-only-bundle-daily.lisp
```

子 plan：`bootstrap-v45-shell-com-only.lisp`（无 `/bin/sh`，`run-stdin` 写 lbin）

### B 轨 — 158KB slice

```bash
# repo 树
$COM run-bootstrap-plan lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-codegen-158k-daily.lisp

# flat bundle
./nano-lisp.com run-bootstrap-plan bootstrap/bootstrap-v45-codegen-158k-bundle-daily.lisp
```

期望：`link.code.bytes=154017` · `compose15_full_codegen=1` · exit **42**

Flat bundle 布局：
```
nano-lisp.com
bootstrap/bootstrap-v45-codegen-158k-bundle-daily.lisp
lisp/lispjit.c              # 触发名 only
lisp/modules-semantic/*
.build/
```

## Gate / smoke

```bash
bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-gate.sh
bash lab/nano-lisp-jit/retired/scripts/nano-jit-com-lisp-only-smoke.sh
bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-codegen-158k-smoke.sh
```

c-gate 顺序：verify → com-lisp-only → codegen-158k → shell noarg/fgets/full-c

## 关键源码

| 文件 | 内容 |
|------|------|
| `lab/nano-lisp-jit/retired/archive-c/runner/nano_bootstrap.c` | bootstrap DSL · compose15 · `lisp-root` · `nano_lisp_join` |
| `lab/nano-lisp-jit/retired/archive-c/runner/nano_run_cli.c` | `cmd_run_stdin` |
| `lab/lispjit-ir/nano_types.h` | `BOOTSTRAP_STEP_*` 43–45 |
| `lab/nano-lisp-jit/archive/c/runner` | → `retired/archive-c/runner` symlink |

## 已 merge PR

#192 run-stdin + flat COM+Lisp bundle · #193 build-slice-lisp-profile 158k daily · flat bundle `lisp-root` 已 fast-forward **main**

## 踩坑备忘

- **flat bundle spawn**：须 `./nano-lisp.com`，裸名 execvp 找不到
- **com-lisp-only smoke**：勿 overlay release COM（破坏 manifest）；release COM 已含 `run-stdin`
- **audit grep**：`build-slice-lisp-profile` 勿误匹配 `build-slice-compile` 模式
- **full-c smoke**：`PLAN_RUNNER` 须 save/restore，防 probe 脚本 clobber `C_COM`
- **run-stdin 子进程**：`fflush` before `_exit`，否则 stdout 缓冲丢字节

## 诚实 GAP / 下一刀

1. **863KB 全 COM 纯 Lisp 自举（零 extract）** — plan-only regenesis **871KB 已通**；slice 纯 codegen 仍 ~161KB
2. ~~compose15 默认 profile hybrid~~ — ✅ profile_upgrade + NO_HYBRID
3. **路径** — ✅ lisp-root + bootstrap_plan_path
4. **Rust 轨**：dual-gate 独立；rs compose15 semantic smoke 已有
5. **OS libc** — 短期不可避免

## 开新会话建议顺序

1. `bash lab/nano-lisp-jit/retired/scripts/nano-jit-c-gate.sh` 确认绿
2. 改 bootstrap DSL → host-cc 测 → promote → 更新 manifest/README
3. 攻 **B′**：全 COM codegen（非 158KB slice）或统一 A+B 顶层 entry plan
4. 勿把 A 轨「plan 无 .sh」说成「零第三方」

## 分支约定（cloud agent）

新分支：`cursor/<desc>-fc19` off `main`
