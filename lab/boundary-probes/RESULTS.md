# nano-lisp-jit 能力边界探测

自动生成：`bash lab/boundary-probes/run-probes.sh`

| 探测 | 阶段 | 结果 | 预期 |
|------|------|------|------|
| empty-main | compile+run | ok | pass |
| i64-extremes | compile+run | ok | pass |
| deep-branch-chain | compile+run | ok | pass |
| multi-func-lbin | compile | fail:3 | fail |
| branch-label-not-barrier | compile+run | fail:19 | fail_run |
| ptr-arith-large-offset | compile+run | ok | pass |
| many-imports-resolve | compile+run | ok | pass |
| many-ops-u64 | compile+run | ok | pass |
| duplicate-label-bad | compile | fail:3 | fail |
| missing-main-bad | compile | fail:3 | fail |
| unknown-import-bad | resolve | fail | resolve_fail |
| call-wrong-ret-bad | compile | fail:3 | fail_or_misrun |
| call-wrong-ret-aot | compile-elf64-code | fail:1 | fail |
| aot-i64-extremes-vm | compile+run | ok | pass |
| i64-aot-unsupported-vm | compile+run | ok | pass |
| multi-func-chain-aot | compile-elf64-exe+run | ok | pass |
| many-ops-u64-aot | aot-elf64-code+run | ok | pass |
| i64-42-codegen | compile-elf64+run | ok | pass |
| i64-min-codegen | compile-elf64-code | unsupported_source | fail |
| i64-min-aot-blob | aot-elf64-code | unsupported_blob | fail |

## 解读摘要

见 `BOUNDARY-NOTES.md`（人工归纳的能力上限与差异）。
