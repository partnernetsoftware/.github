# Wave60 — ci-shell-retire（最后 wave converge 退 retired · physical.zero_cpysh=1）

**签收**：`v45.v45.ci_shell_retire_continue.100=1` + **`v45.physical.zero_cpysh=1`** — **wave59 `.sh` 迁 `retired/scripts/` + 用户 daily 纯 plan**（**≠ 全 monorepo 零 C · ≠ v4.5 DONE**）。

| 轨 | plan |
|----|------|
| W1 | `ci-shell-plan-only-replacement-prove.lisp` |
| W2 | `ci-shell-archive-honest.lisp` |
| W3 | `converge-daily-v45-physical-zero-cpysh.lisp` |
| W4 | `selfhost-ci-shell-retire-matrix.lisp` |

收敛脚本会执行：`scripts/v45-wave59*.sh` → `retired/scripts/`

```bash
bash lab/nano-lisp-jit/scripts/v45-wave60-ci-shell-retire-converge.sh
grep v45.physical.zero_cpysh=1 lab/nano-lisp-jit/.build/v45-entry.evidence
grep v45.v45.ci_shell_retire_continue.100=1 lab/nano-lisp-jit/.build/v45-entry.evidence
```

**诚实未达**：`archive/c/` 工厂 C · CI 工具 `v45-evidence-canonical.sh` 等 · wave60 `.sh` 壳
