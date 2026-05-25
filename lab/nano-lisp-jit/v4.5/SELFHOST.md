# v4.5 完全自举（`*.lisp` 路线图）

> **scoped 100%** = 发行面验收 ✅ · **完全自举** = 本文件阶梯（未全达）

## 阶梯定义

| 阶 | ID | 含义 | 验收 plan | 证据键 |
|----|-----|------|-----------|--------|
| S0 | seed | `genesis` + `nano-jit.com` 可跑 plan | `bootstrap-v45-entry` | （scoped） |
| S1 | genesis-pin | `.com` 建 runner slice ≡ genesis | `build-slice-genesis` | `v45.build.no_host_cc` |
| S2 | **lisp-slice** | `build-slice` 源为 **`.lisp`**（非 plan 内 `.c`） | `bootstrap-v45-build-slice-lisp` | `v45.selfhost.lisp_slice=1` |
| S3 | **modules** | `lispjit-modules/*.lisp` VM 链 | `bootstrap-v45-selfhost-modules` | `v45.selfhost.modules=1` |
| S4 | **regenesis** | seed `.com` → `pack-ape` 出 **next.com** | `bootstrap-v45-selfhost-regenesis` | `v45.selfhost.regenesis=1` |
| S5 | **chain** | S1–S4 单 plan 串联 | `bootstrap-v45-selfhost-chain` | `v45.selfhost.chain=1` |
| T3 | no-c-src | `lispjit.c` 真源在 `archive/runner/` | ✅ | `v45.runner.no_c_src=1` |
| T4 | vm-emit | `ir-table-lisp` + VM/AOT smoke | ✅ | `v45.codegen.vm_emit=1` |

**完全自举（用户口径）** ≈ **S5 + T3 + 代际矩阵**；Wave19 签收 **`v45.selfhost.100=1`**（`v45-wave19-selfhost-converge.sh`）。

## 与 v4 子轨关系

| v4 | v4.5 |
|----|------|
| gen57 `semantic-terminal` | 链入 `selfhost-chain` compare |
| gen60 `lispjit-from-lisp DONE` | `handoff` + `selfhost-terminal` 锚点 |
| zero-host gen2 regenesis | `selfhost-regenesis` 复刻（`.com` 打下一颗 `.com`） |

v4 证明 **引擎能**；v4.5 把证明迁到 **发行面 plan**（无 `run.sh` 步骤）。

## 验收（com-only）

```bash
COM=lab/nano-lisp-jit/.build/nano-jit/nano-jit.com
export -n NANO_SELFHOST_REUSE_X86 NANO_SELFHOST_REUSE_AARCH64 \
  NANO_BUILD_SLICE_SELFHOST_REUSE NANO_REGENESIS 2>/dev/null || true

for p in build-slice-lisp selfhost-modules selfhost-regenesis selfhost-chain selfhost-terminal; do
  $COM run-bootstrap-plan lab/nano-lisp-jit/samples/bootstrap-v45-$p.lisp
done

grep -E 'v45\.selfhost\.(lisp_slice|modules|regenesis|chain)=' \
  lab/nano-lisp-jit/.build/v45-entry.evidence
```

## Wave19（✅ 完全自举签收）

| 键 | 含义 |
|----|------|
| `v45.selfhost.100=1` | S5+T3 + `next_verify_matrix` + `lisp_only_chain` |
| `v45.selfhost.next_verify_matrix=1` | `next.com` 跑 `verify-smoke` / `verify-core` / `onion-tdd` |
| `v45.selfhost.lisp_only_chain=1` | plan 零 `lispjit.c` → `v45-w19-lisp-gen2.com` |
| `v45.selfhost.gen2_distinct=1` | gen2 `.com` hash ≠ seed |

见 [`DIFFUSE-WAVE19.md`](DIFFUSE-WAVE19.md)。

## 诚实未达（工厂/物理层，与自举卷分离）

| 项 | 说明 |
|----|------|
| plan 内 `build-slice lispjit.c` | S4/S5 仍可用 C 路径产 slice（**日常 host 不 cc**） |
| `run.sh` / squad.sh | 工厂层；tier3 退役 |
| 15 TU 全链接 codegen | v4 gen60 级；v4.5 先 modules smoke |

## Wave2 并入（扩散，非逐阶几十年）

| 阶 | 状态 | 说明 |
|----|------|------|
| S6 next.com smoke | ✅ | `v45-wave2-converge.sh` |
| S7 modules 13/13 | ✅ | `selfhost-modules-full.lisp` |
| S8 factory matrix | ✅ | `factory-matrix.lisp` |
| S9 next 全矩阵 | ✅ | Wave19 `next_verify_matrix` |
| S10 lisp-only gen2 | ✅ | `selfhost-lisp-only-chain.lisp` |

见 [`DIFFUSE-WAVE2.md`](DIFFUSE-WAVE2.md) · [`CONCURRENT-IMPL.md`](CONCURRENT-IMPL.md)。

## Wave3（✅ 工厂收敛）

- `v45-wave4-converge.sh` 跑全部 `bootstrap-v45-*.lisp` + **next.com onion-tdd**
- `v45-wave3-converge.sh` 仍可作为 wave3 子集（wave4 内嵌调用）
- `wave3-lisp-only-regenesis` — plan 内 **零 lispjit.c** → `v45-w3-lisp-only.com`
- `run.sh` v4.5 段 **1 case**；662× wave → `archive/samples/v4-waves/`

见 [`DIFFUSE-WAVE3.md`](DIFFUSE-WAVE3.md)。Wave4：tier3 runner 出仓。
