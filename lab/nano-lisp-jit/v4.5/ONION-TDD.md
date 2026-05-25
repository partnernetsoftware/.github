# v4.5 洋葱 TDD（仅 `*.lisp` + `nano-jit.com`）

## 入口

```bash
# 从 repo root — 唯一二进制入口
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com

# build-slice compare 须 genesis-pin（勿走 selfhost-reuse）
export -n NANO_SELFHOST_REUSE_X86 NANO_SELFHOST_REUSE_AARCH64 \
  NANO_BUILD_SLICE_SELFHOST_REUSE NANO_REGENESIS 2>/dev/null || true
# 或：env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64 \
#       -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS $COM run-bootstrap-plan …

# 洋葱主门禁（tier2 genesis + VM + APE + compare）
$COM run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-onion-tdd.lisp

# 完整 verify 矩阵
for p in verify-smoke verify-core v4-handoff build-slice-genesis \
  boundary-probe boundary-negative verify-all entry; do
  $COM run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp
done

# scoped 100% 签收
$COM run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-terminal-done.lisp
grep v45.scoped.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

## 与 `run.sh` 的关系

| 层 | 载体 | 角色 |
|----|------|------|
| **洋葱验收** | `bootstrap-v45-*.lisp` + `.com` | **真源**（本文件） |
| **开发工厂** | `run.sh` | 全量回归、生波、证据落盘；**非**用户发行面 |

`run.sh` 仍调用 `.com` 跑 v45 plan 以写 `.evidence`；**签收口径**以 plan 为准。

## 洋葱圈（v4.5 scoped）

```text
圈 0  seed     genesis/nano-jit.x86_64 + nano-jit.com
圈 1  VM       verify-smoke + boundary/*
圈 2  AOT/APE  verify-core + onion-tdd
圈 3  build    build-slice-genesis（role=genesis-pin）
圈 4  v4 交接  v4-handoff + gen60 锚点
圈 5  DONE     terminal-done
```

## 证据键

| 键 | 含义 |
|----|------|
| `v45.entry.ok=1` | tier0 |
| `v45.verify.plan_only=1` | tier1 com-only verify |
| `v45.build.no_host_cc=1` | tier2 genesis build-slice |
| `v45.onion.lisp_only=1` | onion-tdd 经 .com 绿 |
| `v45.scoped.100=1` | v4.5 scoped 终局 |
