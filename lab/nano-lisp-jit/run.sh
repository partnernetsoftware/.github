#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$LAB_DIR/../.." && pwd)"
cd "$ROOT_DIR"
BUILD_DIR="$LAB_DIR/.build"
SRC="$LAB_DIR/samples/strlen.lisp"
ARITH_SRC="$LAB_DIR/samples/arithmetic.lisp"
ARITH_I64_SRC="$LAB_DIR/samples/arithmetic-i64.lisp"
TYPED_SRC="$LAB_DIR/samples/typed-values.lisp"
PTR_SRC="$LAB_DIR/samples/ptr-values.lisp"
CONST_PTR_SRC="$LAB_DIR/samples/const-ptr-load-u8.lisp"
RODATA_READONLY_SRC="$LAB_DIR/samples/rodata-readonly.lisp"
CTRL_SRC="$LAB_DIR/samples/control-flow.lisp"
MULTI_SRC="$LAB_DIR/samples/multi-func.lisp"
MULTI_CTRL_SRC="$LAB_DIR/samples/multi-func-control-flow.lisp"
MULTI_PTR_SRC="$LAB_DIR/samples/multi-func-ptr.lisp"
FUNC_PARAM_I64_SRC="$LAB_DIR/samples/func-param-i64.lisp"
FUNC_PARAM_VM_PARITY_SRC="$LAB_DIR/samples/func-param-vm-parity.lisp"
FUNC_PARAM_VM_PARITY_BLOB="$BUILD_DIR/func-param-vm-parity.lbin"
FUNC_PARAM_MISSING_PARAM_BAD_SRC="$LAB_DIR/samples/func-param-missing-param-bad.lisp"
FUNC_PARAM_CALL_NO_ARG_BAD_SRC="$LAB_DIR/samples/func-param-call-no-arg-bad.lisp"
TYPE_BAD_PTR_OP_SRC="$LAB_DIR/samples/type-error-ptr-op-bad.lisp"
TYPE_BAD_ADD_PTR_SRC="$LAB_DIR/samples/type-error-add-ptr-bad.lisp"
TYPE_BAD_SUB_PTR_SRC="$LAB_DIR/samples/type-error-sub-ptr-bad.lisp"
TYPE_BAD_PTR_TO_U64_SRC="$LAB_DIR/samples/type-error-ptr-to-u64-bad.lisp"
TYPE_BAD_U64_TO_PTR_SRC="$LAB_DIR/samples/type-error-u64-to-ptr-bad.lisp"
TYPE_BAD_LOAD_U8_SRC="$LAB_DIR/samples/type-error-load-u8-bad.lisp"
TYPE_BAD_LOAD_U16_SRC="$LAB_DIR/samples/type-error-load-u16-bad.lisp"
TYPE_BAD_LOAD_U32_SRC="$LAB_DIR/samples/type-error-load-u32-bad.lisp"
TYPE_BAD_STORE_U8_SRC="$LAB_DIR/samples/type-error-store-u8-bad.lisp"
TYPE_BAD_STORE_U8_RANGE_SRC="$LAB_DIR/samples/type-error-store-u8-range-bad.lisp"
TYPE_BAD_STORE_U16_SRC="$LAB_DIR/samples/type-error-store-u16-bad.lisp"
TYPE_BAD_STORE_U16_RANGE_SRC="$LAB_DIR/samples/type-error-store-u16-range-bad.lisp"
TYPE_BAD_STORE_U32_SRC="$LAB_DIR/samples/type-error-store-u32-bad.lisp"
TYPE_BAD_STORE_U32_RANGE_SRC="$LAB_DIR/samples/type-error-store-u32-range-bad.lisp"
TYPE_BAD_BRANCH_SRC="$LAB_DIR/samples/type-error-branch-bad.lisp"
TYPE_BAD_EXPECT_PTR_SRC="$LAB_DIR/samples/type-error-expect-ptr-bad.lisp"
BOOTSTRAP_SRC="$LAB_DIR/samples/bootstrap-smoke.lisp"
BOOTSTRAP_AOT_SRC="$LAB_DIR/samples/bootstrap-aot-smoke.lisp"
BOOTSTRAP_ABI_SRC="$LAB_DIR/samples/bootstrap-abi-smoke.lisp"
BOOTSTRAP_APE_SRC="$LAB_DIR/samples/bootstrap-ape-smoke.lisp"
BOOTSTRAP_APE_NEG_SRC="$LAB_DIR/samples/bootstrap-ape-negative.lisp"
BOOTSTRAP_DATA_NEG_SRC="$LAB_DIR/samples/bootstrap-data-negative.lisp"
BOOTSTRAP_V25_NATIVE_SELFPACK_SRC="$LAB_DIR/samples/bootstrap-v25-native-selfpack.lisp"
BOOTSTRAP_V3_PACK_BARE_SRC="$LAB_DIR/samples/bootstrap-v3-pack-bare.lisp"
BOOTSTRAP_V3_BUILD_SLICE_SRC="$LAB_DIR/samples/bootstrap-v3-build-slice.lisp"
BOOTSTRAP_V3_BUILD_GRAPH_SRC="$LAB_DIR/samples/bootstrap-v3-build-graph.lisp"
FUNC_CALL_VM_SMOKE_SRC="$LAB_DIR/samples/func-call-vm-smoke.lisp"
FUNC_CALL_VM_SMOKE_BLOB="$BUILD_DIR/func-call-vm-smoke.lbin"
FUNC_PARAM_VM_I64_SRC="$LAB_DIR/samples/func-param-vm-i64.lisp"
FUNC_PARAM_VM_I64_BLOB="$BUILD_DIR/func-param-vm-i64.lbin"
BOOTSTRAP_V3_VM_MATRIX_SRC="$LAB_DIR/samples/bootstrap-v3-vm-selfpack-matrix.lisp"
BOOTSTRAP_V3_SELFHOST_GEN1_SRC="$LAB_DIR/samples/bootstrap-v3-selfhost-gen1.lisp"
BOOTSTRAP_V3_SELFHOST_GEN2_SRC="$LAB_DIR/samples/bootstrap-v3-selfhost-gen2.lisp"
BOOTSTRAP_V3_BUILD_SLICE_LISP_SRC="$LAB_DIR/samples/bootstrap-v3-build-slice-lisp.lisp"
BOOTSTRAP_V3_CODEGEN_SMOKE_SRC="$LAB_DIR/samples/bootstrap-v3-codegen-smoke.lisp"
BOOTSTRAP_V35_NANO_CC_HELLO_SRC="$LAB_DIR/samples/bootstrap-v35-nano-cc-hello.lisp"
BOOTSTRAP_V35_NANO_CC_ADD_SRC="$LAB_DIR/samples/bootstrap-v35-nano-cc-add.lisp"
BOOTSTRAP_V35_BUILD_SLICE_SRC="$LAB_DIR/samples/bootstrap-v35-build-slice.lisp"
BOOTSTRAP_V35_SELFHOST_GEN3_SRC="$LAB_DIR/samples/bootstrap-v35-selfhost-gen3.lisp"
BOOTSTRAP_V35_LISP_ONLY_MATRIX_SRC="$LAB_DIR/samples/bootstrap-v35-lisp-only-matrix.lisp"
BOOTSTRAP_V35_BUILD_SLICE_LISP_ROUTE_SRC="$LAB_DIR/samples/bootstrap-v35-build-slice-lisp-route.lisp"
BOOTSTRAP_V35_PACK_LISP_X86_SRC="$LAB_DIR/samples/bootstrap-v35-pack-lisp-x86.lisp"
BOOTSTRAP_V35_SELFHOST_GEN4_SRC="$LAB_DIR/samples/bootstrap-v35-selfhost-gen4.lisp"
BOOTSTRAP_V35_SELFHOST_GEN5_SRC="$LAB_DIR/samples/bootstrap-v35-selfhost-gen5.lisp"
BOOTSTRAP_V35_SELFHOST_GEN5_GEN2_SRC="$LAB_DIR/samples/bootstrap-v35-selfhost-gen5-gen2.lisp"
BOOTSTRAP_V35_SELFHOST_GEN5_VIA_GEN2_SRC="$LAB_DIR/samples/bootstrap-v35-selfhost-gen5-via-gen2.lisp"
BOOTSTRAP_V35_SIGNOFF_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v35-signoff-evidence.lisp"
BOOTSTRAP_V4_KICKOFF_SRC="$LAB_DIR/samples/bootstrap-v4-kickoff.lisp"
BOOTSTRAP_V4_AARCH64_AOT_SRC="$LAB_DIR/samples/bootstrap-v4-aarch64-aot-plan.lisp"
BOOTSTRAP_V4_SQUAD_DISPATCH_SRC="$LAB_DIR/samples/bootstrap-v4-squad-dispatch.lisp"
BOOTSTRAP_V4_SQUAD_RUN_LOOP_ONCE_SRC="$LAB_DIR/samples/bootstrap-v4-squad-run-loop-once.lisp"
BOOTSTRAP_V4_SLICE0_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice0-evidence.lisp"
V4_SLICE0_EVIDENCE="$BUILD_DIR/v4-slice0.evidence"
BOOTSTRAP_V4_SLICE1_ADD7_SRC="$LAB_DIR/samples/bootstrap-v4-slice1-add7.lisp"
BOOTSTRAP_V4_SLICE1_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice1-evidence.lisp"
BOOTSTRAP_V4_SQUAD_SIGNAL_SRC="$LAB_DIR/samples/bootstrap-v4-squad-signal.lisp"
V4_AARCH64_SCOUT_ELF="$BUILD_DIR/bootstrap-v4-aarch64-add-scout.elf"
V4_SLICE1_ADD7_ELF="$BUILD_DIR/bootstrap-v4-slice1-add7.elf"
V4_SLICE1_EVIDENCE="$BUILD_DIR/v4-slice1.evidence"
BOOTSTRAP_V4_GEN5_ANCHOR_SRC="$LAB_DIR/samples/bootstrap-v4-gen5-anchor.lisp"
V4_LISP_ONLY_EVIDENCE="$BUILD_DIR/v4-lisp-only.evidence"
BOOTSTRAP_V4_SQUAD_S2_STATE_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s2-state.lisp"
BOOTSTRAP_V4_GEN5_VIA_GEN2_ANCHOR_SRC="$LAB_DIR/samples/bootstrap-v4-gen5-via-gen2-anchor.lisp"
BOOTSTRAP_V4_SLICE2_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice2-evidence.lisp"
V4_SLICE2_EVIDENCE="$BUILD_DIR/v4-slice2.evidence"
BOOTSTRAP_V4_SQUAD_S3_SUPERVISE_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s3-supervise-once.lisp"
BOOTSTRAP_V4_SQUAD_S3_MEMBER_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s3-member-once.lisp"
BOOTSTRAP_V4_SLICE3_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice3-evidence.lisp"
V4_SLICE3_EVIDENCE="$BUILD_DIR/v4-slice3.evidence"
BOOTSTRAP_V4_SQUAD_S4_AGENT_TEAM_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s4-agent-team.lisp"
BOOTSTRAP_V4_SLICE4_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice4-evidence.lisp"
V4_SLICE4_EVIDENCE="$BUILD_DIR/v4-slice4.evidence"
BOOTSTRAP_V4_SQUAD_S5_VERIFY_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s5-verify-plan.lisp"
BOOTSTRAP_V4_SLICE5_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice5-evidence.lisp"
V4_SLICE5_EVIDENCE="$BUILD_DIR/v4-slice5.evidence"
BOOTSTRAP_V4_CODEGEN_KICKOFF_SRC="$LAB_DIR/samples/bootstrap-v4-codegen-kickoff.lisp"
BOOTSTRAP_V4_SLICE6_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice6-evidence.lisp"
V4_SLICE6_EVIDENCE="$BUILD_DIR/v4-slice6.evidence"
BOOTSTRAP_V4_SLICE7_ADD11_SRC="$LAB_DIR/samples/bootstrap-v4-slice7-add11.lisp"
BOOTSTRAP_V4_SLICE7_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice7-evidence.lisp"
V4_SLICE7_ADD11_ELF="$BUILD_DIR/bootstrap-v4-slice7-add11.elf"
V4_SLICE7_EVIDENCE="$BUILD_DIR/v4-slice7.evidence"
BOOTSTRAP_V4_SLICE8_ADD13_SRC="$LAB_DIR/samples/bootstrap-v4-slice8-add13.lisp"
BOOTSTRAP_V4_SLICE8_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice8-evidence.lisp"
V4_SLICE8_ADD13_ELF="$BUILD_DIR/bootstrap-v4-slice8-add13.elf"
V4_SLICE8_EVIDENCE="$BUILD_DIR/v4-slice8.evidence"
BOOTSTRAP_V4_SLICE9_ADD14_SRC="$LAB_DIR/samples/bootstrap-v4-slice9-add14.lisp"
BOOTSTRAP_V4_SLICE9_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice9-evidence.lisp"
V4_SLICE9_ADD14_ELF="$BUILD_DIR/bootstrap-v4-slice9-add14.elf"
V4_SLICE9_EVIDENCE="$BUILD_DIR/v4-slice9.evidence"
BOOTSTRAP_V4_SLICE10_IR_ENTRY_SRC="$LAB_DIR/samples/bootstrap-v4-slice10-ir-entry.lisp"
BOOTSTRAP_V4_SLICE10_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice10-evidence.lisp"
BOOTSTRAP_V4_SQUAD_S6_ASSESS_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s6-assess.lisp"
V4_SLICE10_ADD15_ELF="$BUILD_DIR/bootstrap-v4-slice10-add15.elf"
V4_SLICE10_EVIDENCE="$BUILD_DIR/v4-slice10.evidence"
BOOTSTRAP_V4_SLICE11_IR_TABLE_SRC="$LAB_DIR/samples/bootstrap-v4-slice11-ir-table.lisp"
BOOTSTRAP_V4_SLICE11_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice11-evidence.lisp"
BOOTSTRAP_V4_SQUAD_S6_DISPATCH_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s6-dispatch.lisp"
V4_SLICE11_ADD16_ELF="$BUILD_DIR/bootstrap-v4-slice11-add16.elf"
V4_SLICE11_EVIDENCE="$BUILD_DIR/v4-slice11.evidence"
BOOTSTRAP_V4_SLICE12_IR_TABLE_V3_SRC="$LAB_DIR/samples/bootstrap-v4-slice12-ir-table-v3.lisp"
BOOTSTRAP_V4_SLICE12_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice12-evidence.lisp"
BOOTSTRAP_V4_SLICE13_EMIT_MANIFEST_SRC="$LAB_DIR/samples/bootstrap-v4-slice13-emit-manifest.lisp"
BOOTSTRAP_V4_SLICE13_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice13-evidence.lisp"
BOOTSTRAP_V4_SQUAD_S7_SIGNAL_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s7-signal.lisp"
BOOTSTRAP_V4_SQUAD_S8_RESUME_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s8-resume.lisp"
BOOTSTRAP_V4_SLICE14_COMPLETE_SRC="$LAB_DIR/samples/bootstrap-v4-slice14-complete.lisp"
V4_SLICE12_ADD17_ELF="$BUILD_DIR/bootstrap-v4-slice12-add17.elf"
V4_SLICE12_EVIDENCE="$BUILD_DIR/v4-slice12.evidence"
V4_SLICE13_EVIDENCE="$BUILD_DIR/v4-slice13.evidence"
BOOTSTRAP_V4_SLICE15_TABLE_ONLY_SRC="$LAB_DIR/samples/bootstrap-v4-slice15-table-only.lisp"
BOOTSTRAP_V4_SLICE15_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice15-evidence.lisp"
BOOTSTRAP_V4_BUILD_GRAPH_SMOKE_SRC="$LAB_DIR/samples/bootstrap-v4-build-graph-smoke.lisp"
BOOTSTRAP_V4_SQUAD_S9_DONE_SRC="$LAB_DIR/samples/bootstrap-v4-squad-s9-done.lisp"
BOOTSTRAP_V4_SQUAD_ASSESS_SCOPED_SRC="$LAB_DIR/samples/bootstrap-v4-squad-assess-scoped-ready.lisp"
V4_SLICE15_ADD18_ELF="$BUILD_DIR/bootstrap-v4-slice15-add18.elf"
V4_SLICE15_EVIDENCE="$BUILD_DIR/v4-slice15.evidence"
V4_TERMINAL_EVIDENCE="$BUILD_DIR/v4-terminal.evidence"
BOOTSTRAP_V4_SLICE16_PLAN_WORDS_SRC="$LAB_DIR/samples/bootstrap-v4-slice16-plan-words.lisp"
BOOTSTRAP_V4_SLICE16_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice16-evidence.lisp"
BOOTSTRAP_V4_SQUAD_MINDMAP_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-squad-mindmap-tick.lisp"
V4_SLICE16_ADD19_ELF="$BUILD_DIR/bootstrap-v4-slice16-add19.elf"
V4_SLICE16_EVIDENCE="$BUILD_DIR/v4-slice16.evidence"
BOOTSTRAP_V4_SLICE17_VERIFY_WORDS_SRC="$LAB_DIR/samples/bootstrap-v4-slice17-verify-words.lisp"
BOOTSTRAP_V4_SLICE17_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice17-evidence.lisp"
BOOTSTRAP_V4_SQUAD_ASSESS_ONCE_SRC="$LAB_DIR/samples/bootstrap-v4-squad-assess-once.lisp"
V4_SLICE17_ADD20_ELF="$BUILD_DIR/bootstrap-v4-slice17-add20.elf"
V4_SLICE17_EVIDENCE="$BUILD_DIR/v4-slice17.evidence"
BOOTSTRAP_V4_SLICE18_IR_TABLE_OP_SRC="$LAB_DIR/samples/bootstrap-v4-slice18-ir-table-op.lisp"
BOOTSTRAP_V4_SLICE18_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice18-evidence.lisp"
BOOTSTRAP_V4_HOST_REDUCE_SRC="$LAB_DIR/samples/bootstrap-v4-host-reduce.lisp"
V4_SLICE18_ADD21_ELF="$BUILD_DIR/bootstrap-v4-slice18-add21.elf"
V4_SLICE18_EVIDENCE="$BUILD_DIR/v4-slice18.evidence"
BOOTSTRAP_V4_WAVE27_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave27-diffusion.lisp"
BOOTSTRAP_V4_BUILD_GRAPH_WAVE27_SRC="$LAB_DIR/samples/bootstrap-v4-build-graph-wave27.lisp"
BOOTSTRAP_V4_SQUAD_ORCH_BUNDLE_SRC="$LAB_DIR/samples/bootstrap-v4-squad-orchestration-bundle.lisp"
BOOTSTRAP_V4_SLICE27_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice27-evidence.lisp"
V4_SLICE27_ADD22_ELF="$BUILD_DIR/bootstrap-v4-slice27-add22.elf"
V4_SLICE27_EVIDENCE="$BUILD_DIR/v4-slice27.evidence"
BOOTSTRAP_V4_WAVE28_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave28-diffusion.lisp"
BOOTSTRAP_V4_BUILD_GRAPH_FULL_SRC="$LAB_DIR/samples/bootstrap-v4-build-graph-full.lisp"
BOOTSTRAP_V4_PLAN_CONTRACT_SRC="$LAB_DIR/samples/bootstrap-v4-plan-contract-bundle.lisp"
BOOTSTRAP_V4_ASSESS_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-assess-evidence-chain.lisp"
BOOTSTRAP_V4_SLICE28_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice28-evidence.lisp"
V4_SLICE28_ADD23_ELF="$BUILD_DIR/bootstrap-v4-slice28-add23.elf"
V4_SLICE28_EVIDENCE="$BUILD_DIR/v4-slice28.evidence"
BOOTSTRAP_V4_WAVE29_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave29-diffusion.lisp"
BOOTSTRAP_V4_SQUAD_FOUR_ROLES_SRC="$LAB_DIR/samples/bootstrap-v4-squad-four-roles.lisp"
BOOTSTRAP_V4_BUILD_GATES_PLAN_SRC="$LAB_DIR/samples/bootstrap-v4-build-gates-plan.lisp"
BOOTSTRAP_V4_PLAN_MANIFEST_ANCHOR_SRC="$LAB_DIR/samples/bootstrap-v4-plan-manifest-anchor.lisp"
BOOTSTRAP_V4_SLICE29_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice29-evidence.lisp"
V4_SLICE29_ADD24_ELF="$BUILD_DIR/bootstrap-v4-slice29-add24.elf"
V4_SLICE29_EVIDENCE="$BUILD_DIR/v4-slice29.evidence"
BOOTSTRAP_V4_WAVE30_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave30-diffusion.lisp"
BOOTSTRAP_V4_SQUAD_SUPERVISE_CHAIN_SRC="$LAB_DIR/samples/bootstrap-v4-squad-supervise-chain.lisp"
BOOTSTRAP_V4_CONTRACT_REGRESSION_SRC="$LAB_DIR/samples/bootstrap-v4-contract-regression.lisp"
BOOTSTRAP_V4_ONION_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-onion-tick.lisp"
BOOTSTRAP_V4_SLICE30_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice30-evidence.lisp"
V4_SLICE30_ADD25_ELF="$BUILD_DIR/bootstrap-v4-slice30-add25.elf"
V4_SLICE30_EVIDENCE="$BUILD_DIR/v4-slice30.evidence"
BOOTSTRAP_V4_WAVE31_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave31-diffusion.lisp"
BOOTSTRAP_V4_SQUAD_COMMANDER_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-squad-commander-tick.lisp"
BOOTSTRAP_V4_EVIDENCE_MATRIX_SRC="$LAB_DIR/samples/bootstrap-v4-evidence-matrix.lisp"
BOOTSTRAP_V4_POST_V4_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-post-v4-tick.lisp"
BOOTSTRAP_V4_SLICE31_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice31-evidence.lisp"
V4_SLICE31_ADD26_ELF="$BUILD_DIR/bootstrap-v4-slice31-add26.elf"
V4_SLICE31_EVIDENCE="$BUILD_DIR/v4-slice31.evidence"
BOOTSTRAP_V4_WAVE32_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave32-diffusion.lisp"
BOOTSTRAP_V4_SQUAD_RESUME_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-squad-resume-tick.lisp"
BOOTSTRAP_V4_LISP_ONLY_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-lisp-only-tick.lisp"
BOOTSTRAP_V4_SLICE32_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice32-evidence.lisp"
V4_SLICE32_ADD27_ELF="$BUILD_DIR/bootstrap-v4-slice32-add27.elf"
V4_SLICE32_EVIDENCE="$BUILD_DIR/v4-slice32.evidence"
BOOTSTRAP_V4_WAVE33_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave33-diffusion.lisp"
BOOTSTRAP_V4_BUILD_GRAPH_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-build-graph-tick.lisp"
BOOTSTRAP_V4_ASSESS_CHAIN_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-assess-chain-tick.lisp"
BOOTSTRAP_V4_SLICE33_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice33-evidence.lisp"
V4_SLICE33_ADD28_ELF="$BUILD_DIR/bootstrap-v4-slice33-add28.elf"
V4_SLICE33_EVIDENCE="$BUILD_DIR/v4-slice33.evidence"
BOOTSTRAP_V4_WAVE34_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave34-diffusion.lisp"
BOOTSTRAP_V4_PLAN_CONTRACT_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-plan-contract-tick.lisp"
BOOTSTRAP_V4_TERMINAL_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-terminal-tick.lisp"
BOOTSTRAP_V4_SLICE34_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice34-evidence.lisp"
V4_SLICE34_ADD29_ELF="$BUILD_DIR/bootstrap-v4-slice34-add29.elf"
V4_SLICE34_EVIDENCE="$BUILD_DIR/v4-slice34.evidence"
BOOTSTRAP_V4_WAVE35_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave35-diffusion.lisp"
BOOTSTRAP_V4_WAVE35_CONTRACT_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave35-contract-tick.lisp"
BOOTSTRAP_V4_WAVE35_REFLECTION_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave35-reflection-tick.lisp"
BOOTSTRAP_V4_SLICE35_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice35-evidence.lisp"
V4_SLICE35_ADD30_ELF="$BUILD_DIR/bootstrap-v4-slice35-add30.elf"
V4_SLICE35_EVIDENCE="$BUILD_DIR/v4-slice35.evidence"
BOOTSTRAP_V4_WAVE36_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave36-diffusion.lisp"
BOOTSTRAP_V4_WAVE36_ORCHESTRATION_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave36-orchestration-tick.lisp"
BOOTSTRAP_V4_WAVE36_DISPATCH_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave36-dispatch-tick.lisp"
BOOTSTRAP_V4_SLICE36_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice36-evidence.lisp"
V4_SLICE36_ADD31_ELF="$BUILD_DIR/bootstrap-v4-slice36-add31.elf"
V4_SLICE36_EVIDENCE="$BUILD_DIR/v4-slice36.evidence"
BOOTSTRAP_V4_WAVE37_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave37-diffusion.lisp"
BOOTSTRAP_V4_WAVE37_GEN5_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave37-gen5-tick.lisp"
BOOTSTRAP_V4_WAVE37_README_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave37-readme-tick.lisp"
BOOTSTRAP_V4_SLICE37_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice37-evidence.lisp"
V4_SLICE37_ADD32_ELF="$BUILD_DIR/bootstrap-v4-slice37-add32.elf"
V4_SLICE37_EVIDENCE="$BUILD_DIR/v4-slice37.evidence"
BOOTSTRAP_V4_WAVE38_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave38-diffusion.lisp"
BOOTSTRAP_V4_WAVE38_AARCH64_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave38-aarch64-tick.lisp"
BOOTSTRAP_V4_WAVE38_SLICE10_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave38-slice10-tick.lisp"
BOOTSTRAP_V4_SLICE38_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice38-evidence.lisp"
V4_SLICE38_ADD33_ELF="$BUILD_DIR/bootstrap-v4-slice38-add33.elf"
V4_SLICE38_EVIDENCE="$BUILD_DIR/v4-slice38.evidence"
BOOTSTRAP_V4_WAVE39_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave39-diffusion.lisp"
BOOTSTRAP_V4_WAVE39_IRTABLE_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave39-irtable-tick.lisp"
BOOTSTRAP_V4_WAVE39_WORDS_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave39-words-tick.lisp"
BOOTSTRAP_V4_SLICE39_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice39-evidence.lisp"
V4_SLICE39_ADD34_ELF="$BUILD_DIR/bootstrap-v4-slice39-add34.elf"
V4_SLICE39_EVIDENCE="$BUILD_DIR/v4-slice39.evidence"
BOOTSTRAP_V4_WAVE40_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave40-diffusion.lisp"
BOOTSTRAP_V4_WAVE40_ONION_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave40-onion-tick.lisp"
BOOTSTRAP_V4_WAVE40_TERMINAL_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave40-terminal-tick.lisp"
BOOTSTRAP_V4_SLICE40_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice40-evidence.lisp"
V4_SLICE40_ADD35_ELF="$BUILD_DIR/bootstrap-v4-slice40-add35.elf"
V4_SLICE40_EVIDENCE="$BUILD_DIR/v4-slice40.evidence"
BOOTSTRAP_V4_WAVE41_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave41-diffusion.lisp"
BOOTSTRAP_V4_WAVE41_EMIT_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave41-emit-tick.lisp"
BOOTSTRAP_V4_WAVE41_SLICE18_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave41-slice18-tick.lisp"
BOOTSTRAP_V4_SLICE41_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice41-evidence.lisp"
V4_SLICE41_ADD36_ELF="$BUILD_DIR/bootstrap-v4-slice41-add36.elf"
V4_SLICE41_EVIDENCE="$BUILD_DIR/v4-slice41.evidence"
BOOTSTRAP_V4_WAVE42_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave42-diffusion.lisp"
BOOTSTRAP_V4_WAVE42_SQUAD_S3_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave42-squad-s3-tick.lisp"
BOOTSTRAP_V4_WAVE42_ASSESS_BUNDLE_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave42-assess-bundle-tick.lisp"
BOOTSTRAP_V4_SLICE42_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice42-evidence.lisp"
V4_SLICE42_ADD37_ELF="$BUILD_DIR/bootstrap-v4-slice42-add37.elf"
V4_SLICE42_EVIDENCE="$BUILD_DIR/v4-slice42.evidence"
BOOTSTRAP_V4_WAVE43_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave43-diffusion.lisp"
BOOTSTRAP_V4_WAVE43_MINDMAP_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave43-mindmap-tick.lisp"
BOOTSTRAP_V4_WAVE43_PROGRESS_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave43-progress-tick.lisp"
BOOTSTRAP_V4_SLICE43_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice43-evidence.lisp"
V4_SLICE43_ADD38_ELF="$BUILD_DIR/bootstrap-v4-slice43-add38.elf"
V4_SLICE43_EVIDENCE="$BUILD_DIR/v4-slice43.evidence"
BOOTSTRAP_V4_WAVE44_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave44-diffusion.lisp"
BOOTSTRAP_V4_WAVE44_IR_WORDS_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave44-ir-words-tick.lisp"
BOOTSTRAP_V4_WAVE44_BUILD_GRAPH_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave44-build-graph-tick.lisp"
BOOTSTRAP_V4_SLICE44_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice44-evidence.lisp"
V4_SLICE44_ADD39_ELF="$BUILD_DIR/bootstrap-v4-slice44-add39.elf"
V4_SLICE44_EVIDENCE="$BUILD_DIR/v4-slice44.evidence"
BOOTSTRAP_V4_WAVE45_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave45-diffusion.lisp"
BOOTSTRAP_V4_WAVE45_GEN5_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave45-gen5-tick.lisp"
BOOTSTRAP_V4_WAVE45_TERMINAL_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave45-terminal-tick.lisp"
BOOTSTRAP_V4_SLICE45_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice45-evidence.lisp"
V4_SLICE45_ADD40_ELF="$BUILD_DIR/bootstrap-v4-slice45-add40.elf"
V4_SLICE45_EVIDENCE="$BUILD_DIR/v4-slice45.evidence"
BOOTSTRAP_V4_WAVE46_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave46-diffusion.lisp"
BOOTSTRAP_V4_WAVE46_KICKOFF_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave46-kickoff-tick.lisp"
BOOTSTRAP_V4_WAVE46_EVIDENCE_MATRIX_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave46-evidence-matrix-tick.lisp"
BOOTSTRAP_V4_SLICE46_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice46-evidence.lisp"
V4_SLICE46_ADD41_ELF="$BUILD_DIR/bootstrap-v4-slice46-add41.elf"
V4_SLICE46_EVIDENCE="$BUILD_DIR/v4-slice46.evidence"
BOOTSTRAP_V4_WAVE47_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave47-diffusion.lisp"
BOOTSTRAP_V4_WAVE47_SUPERVISE_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave47-supervise-tick.lisp"
BOOTSTRAP_V4_WAVE47_COMMANDER_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave47-commander-tick.lisp"
BOOTSTRAP_V4_SLICE47_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice47-evidence.lisp"
V4_SLICE47_ADD42_ELF="$BUILD_DIR/bootstrap-v4-slice47-add42.elf"
V4_SLICE47_EVIDENCE="$BUILD_DIR/v4-slice47.evidence"
BOOTSTRAP_V4_WAVE48_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave48-diffusion.lisp"
BOOTSTRAP_V4_WAVE48_MANIFEST_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave48-manifest-tick.lisp"
BOOTSTRAP_V4_WAVE48_CONTRACT_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave48-contract-tick.lisp"
BOOTSTRAP_V4_SLICE48_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice48-evidence.lisp"
V4_SLICE48_ADD43_ELF="$BUILD_DIR/bootstrap-v4-slice48-add43.elf"
V4_SLICE48_EVIDENCE="$BUILD_DIR/v4-slice48.evidence"
BOOTSTRAP_V4_WAVE49_DIFFUSION_SRC="$LAB_DIR/samples/bootstrap-v4-wave49-diffusion.lisp"
BOOTSTRAP_V4_WAVE49_POSTV4_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave49-postv4-tick.lisp"
BOOTSTRAP_V4_WAVE49_LISP_ONLY_TICK_SRC="$LAB_DIR/samples/bootstrap-v4-wave49-lisp-only-tick.lisp"
BOOTSTRAP_V4_SLICE49_EVIDENCE_SRC="$LAB_DIR/samples/bootstrap-v4-slice49-evidence.lisp"
V4_SLICE49_ADD44_ELF="$BUILD_DIR/bootstrap-v4-slice49-add44.elf"
V4_SLICE49_EVIDENCE="$BUILD_DIR/v4-slice49.evidence"
SQUAD_SH="$ROOT_DIR/tools/squad/squad.sh"
CATALOG_V4="$LAB_DIR/squad/catalog-v4.yaml"
BOOTSTRAP_V35_NANO_CC_AARCH64_SRC="$LAB_DIR/samples/bootstrap-v35-nano-cc-aarch64.lisp"
BOOTSTRAP_V35_BUILD_SLICE_AARCH64_SRC="$LAB_DIR/samples/bootstrap-v35-build-slice-aarch64.lisp"
BOOTSTRAP_V35_BUILD_SLICE_LISP_AARCH64_SRC="$LAB_DIR/samples/bootstrap-v35-build-slice-lisp-aarch64.lisp"
BOOTSTRAP_V35_BUILD_SLICE_LISP_AARCH64_ADD_SRC="$LAB_DIR/samples/bootstrap-v35-build-slice-lisp-aarch64-add.lisp"
BUILD_SLICE_LISP_AARCH64_ADD_ELF="$BUILD_DIR/bootstrap-v35-build-slice-lisp-aarch64-add.elf"
BOOTSTRAP_V35_GENESIS_SHRINK_SRC="$LAB_DIR/samples/bootstrap-v35-genesis-shrink.lisp"
BOOTSTRAP_V35_LISP_TU_LINK_SRC="$LAB_DIR/samples/bootstrap-v35-lisp-tu-link.lisp"
NANO_CC_HELLO_SRC="$LAB_DIR/samples/nano-cc-hello.c"
NANO_CC_ADD_SRC="$LAB_DIR/samples/nano-cc-add.c"
NANO_CC_ADD_BAD_SIG_SRC="$LAB_DIR/samples/nano-cc-add-bad-sig.c"
NANO_CC_ADD_BAD_BODY_SRC="$LAB_DIR/samples/nano-cc-add-bad-body.c"
NANO_CC_ADD_PARSE_GOLDEN="$LAB_DIR/samples/nano-cc-add.parse.golden"
NANO_CC_BUILD_SLICE_SRC="$LAB_DIR/samples/nano-cc-build-slice.c"
NANO_CC_BAD_SRC="$LAB_DIR/samples/nano-cc-bad.c"
NANO_CC_HELLO_ELF="$BUILD_DIR/bootstrap-v35-nano-cc-hello.elf"
NANO_CC_ADD_ELF="$BUILD_DIR/bootstrap-v35-nano-cc-add.elf"
NANO_CC_BUILD_SLICE_ELF="$BUILD_DIR/bootstrap-v35-build-slice.elf"
NANO_CC_BUILD_SLICE_AARCH64_ELF="$BUILD_DIR/bootstrap-v35-build-slice-aarch64.elf"
BUILD_SLICE_LISP_AARCH64_ELF="$BUILD_DIR/bootstrap-v35-build-slice-lisp-aarch64.elf"
NANO_CC_HELLO_AARCH64_ELF="$BUILD_DIR/nano-cc-hello-aarch64.elf"
NANO_CC_HELLO_AARCH64_BOOT_ELF="$BUILD_DIR/bootstrap-v35-nano-cc-aarch64.elf"
NANO_CC_HELLO_CLI_ELF="$BUILD_DIR/nano-cc-hello-cli.elf"
NANO_CC_HELLO_OBJ="$BUILD_DIR/nano-cc-hello.o"
NANO_CC_HELLO_OBJ_EXE="$BUILD_DIR/nano-cc-hello-obj-linked"
NANO_CC_ADD_CLI_ELF="$BUILD_DIR/nano-cc-add-cli.elf"
BOOTSTRAP_V3_SELFHOST_GEN3_SRC="$LAB_DIR/samples/bootstrap-v3-selfhost-gen3.lisp"
SELFHOST_DIR="$LAB_DIR/.build/nano-jit/selfhost"
DATA_GOOD_OBJ="$BUILD_DIR/data-good.o"
DATA_BAD_RELOC_TYPE_OBJ="$BUILD_DIR/data-bad-reloc-type.o"
DATA_BAD_RELOC_SYM_OBJ="$BUILD_DIR/data-bad-reloc-sym.o"
DATA_BAD_SYMBOL_SHNDX_OBJ="$BUILD_DIR/data-bad-symbol-shndx.o"
APE_COM="$BUILD_DIR/bootstrap-ape.com"
SMOKE_SRC="$LAB_DIR/samples/libc-smoke.lisp"
BLOB="$BUILD_DIR/strlen.lbin"
BLOB_REPEAT="$BUILD_DIR/strlen-repeat.lbin"
ARITH_BLOB="$BUILD_DIR/arithmetic.lbin"
ARITH_I64_BLOB="$BUILD_DIR/arithmetic-i64.lbin"
TYPED_BLOB="$BUILD_DIR/typed-values.lbin"
PTR_BLOB="$BUILD_DIR/ptr-values.lbin"
CONST_PTR_BLOB="$BUILD_DIR/const-ptr-load-u8.lbin"
CTRL_BLOB="$BUILD_DIR/control-flow.lbin"
BAD_ARITH_SRC="$LAB_DIR/samples/arithmetic-bad.lisp"
BAD_ARITH_BLOB="$BUILD_DIR/arithmetic-bad.lbin"
CTRL_CODE="$BUILD_DIR/control-flow-code.elf"
CTRL_EXIT="$BUILD_DIR/control-flow-aot.elf"
CTRL_OBJ="$BUILD_DIR/control_flow_obj.o"
CTRL_OBJ_EXE="$BUILD_DIR/control_flow_obj"
CTRL_CODE_OBJ="$BUILD_DIR/control_flow_code_obj.o"
CTRL_LINK_EXE="$BUILD_DIR/control_flow_linked"
CTRL_DIRECT_EXE="$BUILD_DIR/control_flow_direct"
PTR_EXIT="$BUILD_DIR/ptr-values-aot.elf"
PTR_CODE="$BUILD_DIR/ptr-values-code.elf"
PTR_CODE_OBJ="$BUILD_DIR/ptr_values_code_obj.o"
PTR_LINK_EXE="$BUILD_DIR/ptr_values_linked"
PTR_DIRECT_EXE="$BUILD_DIR/ptr_values_direct"
CONST_PTR_EXIT="$BUILD_DIR/const_ptr_load_u8_aot.elf"
CONST_PTR_CODE="$BUILD_DIR/const_ptr_load_u8_code.elf"
CONST_PTR_CODE_OBJ="$BUILD_DIR/const_ptr_load_u8_code.o"
CONST_PTR_LINK_EXE="$BUILD_DIR/const_ptr_load_u8_linked"
CONST_PTR_DIRECT_EXE="$BUILD_DIR/const_ptr_load_u8_direct"
RODATA_READONLY_EXE="$BUILD_DIR/rodata_readonly_direct"
MULTI_OBJ="$BUILD_DIR/multi_func.o"
MULTI_LINK_EXE="$BUILD_DIR/multi_func_linked"
MULTI_CTRL_OBJ="$BUILD_DIR/multi_func_control.o"
MULTI_CTRL_LINK_EXE="$BUILD_DIR/multi_func_control_linked"
MULTI_PTR_OBJ="$BUILD_DIR/multi_func_ptr.o"
MULTI_PTR_LINK_EXE="$BUILD_DIR/multi_func_ptr_linked"
MULTI_PTR_DIRECT_EXE="$BUILD_DIR/multi_func_ptr_direct"
FUNC_PARAM_I64_EXE="$BUILD_DIR/func_param_i64_direct"
FUNC_PARAM_MISSING_PARAM_BAD_OBJ="$BUILD_DIR/func_param_missing_param_bad.o"
FUNC_PARAM_MISSING_PARAM_BAD_EXE="$BUILD_DIR/func_param_missing_param_bad"
FUNC_PARAM_CALL_NO_ARG_BAD_OBJ="$BUILD_DIR/func_param_call_no_arg_bad.o"
FUNC_PARAM_CALL_NO_ARG_BAD_EXE="$BUILD_DIR/func_param_call_no_arg_bad"
FUNC_PARAM_MISSING_PARAM_BAD_LBIN="$BUILD_DIR/func_param_missing_param_bad.lbin"
FUNC_PARAM_CALL_NO_ARG_BAD_LBIN="$BUILD_DIR/func_param_call_no_arg_bad.lbin"
TYPE_BAD_PTR_OP_EXE="$BUILD_DIR/type_error_ptr_op_bad"
TYPE_BAD_PTR_OP_OBJ="$BUILD_DIR/type_error_ptr_op_bad.o"
TYPE_BAD_ADD_PTR_OBJ="$BUILD_DIR/type_error_add_ptr_bad.o"
TYPE_BAD_SUB_PTR_OBJ="$BUILD_DIR/type_error_sub_ptr_bad.o"
TYPE_BAD_PTR_TO_U64_EXE="$BUILD_DIR/type_error_ptr_to_u64_bad"
TYPE_BAD_PTR_TO_U64_OBJ="$BUILD_DIR/type_error_ptr_to_u64_bad.o"
TYPE_BAD_U64_TO_PTR_EXE="$BUILD_DIR/type_error_u64_to_ptr_bad"
TYPE_BAD_U64_TO_PTR_OBJ="$BUILD_DIR/type_error_u64_to_ptr_bad.o"
TYPE_BAD_LOAD_U8_EXE="$BUILD_DIR/type_error_load_u8_bad"
TYPE_BAD_LOAD_U8_OBJ="$BUILD_DIR/type_error_load_u8_bad.o"
TYPE_BAD_LOAD_U16_EXE="$BUILD_DIR/type_error_load_u16_bad"
TYPE_BAD_LOAD_U16_OBJ="$BUILD_DIR/type_error_load_u16_bad.o"
TYPE_BAD_LOAD_U32_EXE="$BUILD_DIR/type_error_load_u32_bad"
TYPE_BAD_LOAD_U32_OBJ="$BUILD_DIR/type_error_load_u32_bad.o"
TYPE_BAD_STORE_U8_EXE="$BUILD_DIR/type_error_store_u8_bad"
TYPE_BAD_STORE_U8_OBJ="$BUILD_DIR/type_error_store_u8_bad.o"
TYPE_BAD_STORE_U8_RANGE_EXE="$BUILD_DIR/type_error_store_u8_range_bad"
TYPE_BAD_STORE_U8_RANGE_OBJ="$BUILD_DIR/type_error_store_u8_range_bad.o"
TYPE_BAD_STORE_U16_EXE="$BUILD_DIR/type_error_store_u16_bad"
TYPE_BAD_STORE_U16_OBJ="$BUILD_DIR/type_error_store_u16_bad.o"
TYPE_BAD_STORE_U16_RANGE_EXE="$BUILD_DIR/type_error_store_u16_range_bad"
TYPE_BAD_STORE_U16_RANGE_OBJ="$BUILD_DIR/type_error_store_u16_range_bad.o"
TYPE_BAD_STORE_U32_EXE="$BUILD_DIR/type_error_store_u32_bad"
TYPE_BAD_STORE_U32_OBJ="$BUILD_DIR/type_error_store_u32_bad.o"
TYPE_BAD_STORE_U32_RANGE_EXE="$BUILD_DIR/type_error_store_u32_range_bad"
TYPE_BAD_STORE_U32_RANGE_OBJ="$BUILD_DIR/type_error_store_u32_range_bad.o"
TYPE_BAD_BRANCH_EXE="$BUILD_DIR/type_error_branch_bad"
TYPE_BAD_EXPECT_PTR_OBJ="$BUILD_DIR/type_error_expect_ptr_bad.o"
SMOKE_BLOB="$BUILD_DIR/libc-smoke.lbin"
LIBC_SRC="$BUILD_DIR/libc-resolve.lisp"
LIBC_BLOB="$BUILD_DIR/libc-resolve.lbin"
EXIT42="$BUILD_DIR/exit42.elf"
ARITH_EXIT="$BUILD_DIR/arithmetic-aot.elf"
ARITH_CODE="$BUILD_DIR/arithmetic-code.elf"
ARITH_I64_CODE="$BUILD_DIR/arithmetic-i64-code.elf"
BAD_ARITH_CODE="$BUILD_DIR/arithmetic-bad-code.elf"
RET42_OBJ="$BUILD_DIR/nano_ret42.o"
RET42_EXE="$BUILD_DIR/nano_ret42"
ARITH_OBJ="$BUILD_DIR/arithmetic_obj.o"
ARITH_OBJ_EXE="$BUILD_DIR/arithmetic_obj"
ARITH_CODE_OBJ="$BUILD_DIR/arithmetic_code_obj.o"
ARITH_I64_CODE_OBJ="$BUILD_DIR/arithmetic_i64_code_obj.o"
ARITH_I64_LINK_EXE="$BUILD_DIR/arithmetic_i64_linked"
ARITH_LINK_EXE="$BUILD_DIR/arithmetic_linked"
ARITH_DIRECT_EXE="$BUILD_DIR/arithmetic_direct"
ARITH_I64_DIRECT_EXE="$BUILD_DIR/arithmetic_i64_direct"
ARITH_I64_DIRECT_OBJ="$BUILD_DIR/arithmetic_i64_direct.o"
ARITH_I64_DIRECT_LINK_EXE="$BUILD_DIR/arithmetic_i64_direct_linked"
ARITH_DIRECT_OBJ="$BUILD_DIR/arithmetic_direct.o"
ARITH_DIRECT_OBJ_EXE="$BUILD_DIR/arithmetic_direct_obj"
CALL42_OBJ="$BUILD_DIR/nano_call42.o"
CALL42_CALLEE_OBJ="$BUILD_DIR/nano_ext42.o"
CALL42_LINK_EXE="$BUILD_DIR/nano_call42_linked"
CONST_PTR_CALL_OBJ="$BUILD_DIR/const_ptr_call.o"
CONST_PTR_CALLEE_OBJ="$BUILD_DIR/const_ptr_callee.o"
CONST_PTR_CROSS_LINK_EXE="$BUILD_DIR/const_ptr_cross_obj_linked"
DUP42_OBJ="$BUILD_DIR/nano_dup42.o"
NANO_JIT_DIR="$LAB_DIR/.build/nano-jit"
NANO_JIT_COM="$NANO_JIT_DIR/nano-jit.com"
RUNNER="$BUILD_DIR/nano-lisp-jit"
RESULTS="$BUILD_DIR/results.txt"
V35_SIGNOFF_EVIDENCE="$BUILD_DIR/v35-signoff.evidence"
V35_TERMINAL_EVIDENCE="$BUILD_DIR/v35-terminal.evidence"
: >"$V35_SIGNOFF_EVIDENCE"
: >"$V35_TERMINAL_EVIDENCE"
NANO_C="$ROOT_DIR/lab/lispjit-ir/lispjit.c"

mkdir -p "$BUILD_DIR"
: > "$RESULTS"

log() {
  printf '%s\n' "$*" | tee -a "$RESULTS"
}

bytes_of() {
  "$RUNNER" file-size "$1"
}

# shellcheck source=skip_registry.sh
source "$LAB_DIR/skip_registry.sh"
# shellcheck source=audit_genesis_shrink.sh
source "$LAB_DIR/audit_genesis_shrink.sh"

# has_qemu_aarch64 from skip_registry.sh

log "# nano-lisp-jit .lisp to .lbin probe"

run_case "build-native-nano-lisp-jit" cc -DNANO_LISP_JIT -Os -s "$NANO_C" -ldl -o "$RUNNER"

run_case "verify-lispjit-tu" bash "$LAB_DIR/verify_tu.sh"

log "source.path=$SRC"
log "source.bytes=$(bytes_of "$SRC")"
log "arithmetic.source.path=$ARITH_SRC"
log "arithmetic.source.bytes=$(bytes_of "$ARITH_SRC")"
log "arithmetic.i64.source.path=$ARITH_I64_SRC"
log "arithmetic.i64.source.bytes=$(bytes_of "$ARITH_I64_SRC")"
log "typed.source.path=$TYPED_SRC"
log "typed.source.bytes=$(bytes_of "$TYPED_SRC")"
log "ptr.source.path=$PTR_SRC"
log "ptr.source.bytes=$(bytes_of "$PTR_SRC")"
log "const.ptr.source.path=$CONST_PTR_SRC"
log "const.ptr.source.bytes=$(bytes_of "$CONST_PTR_SRC")"
log "control.source.path=$CTRL_SRC"
log "control.source.bytes=$(bytes_of "$CTRL_SRC")"
log "multi.source.path=$MULTI_SRC"
log "multi.source.bytes=$(bytes_of "$MULTI_SRC")"
log "multi.ctrl.source.path=$MULTI_CTRL_SRC"
log "multi.ctrl.source.bytes=$(bytes_of "$MULTI_CTRL_SRC")"
log "multi.ptr.source.path=$MULTI_PTR_SRC"
log "multi.ptr.source.bytes=$(bytes_of "$MULTI_PTR_SRC")"
log "type.bad.ptr.op.source.path=$TYPE_BAD_PTR_OP_SRC"
log "type.bad.ptr.op.source.bytes=$(bytes_of "$TYPE_BAD_PTR_OP_SRC")"
log "type.bad.add.ptr.source.path=$TYPE_BAD_ADD_PTR_SRC"
log "type.bad.add.ptr.source.bytes=$(bytes_of "$TYPE_BAD_ADD_PTR_SRC")"
log "type.bad.sub.ptr.source.path=$TYPE_BAD_SUB_PTR_SRC"
log "type.bad.sub.ptr.source.bytes=$(bytes_of "$TYPE_BAD_SUB_PTR_SRC")"
log "type.bad.ptr.to.u64.source.path=$TYPE_BAD_PTR_TO_U64_SRC"
log "type.bad.ptr.to.u64.source.bytes=$(bytes_of "$TYPE_BAD_PTR_TO_U64_SRC")"
log "type.bad.u64.to.ptr.source.path=$TYPE_BAD_U64_TO_PTR_SRC"
log "type.bad.u64.to.ptr.source.bytes=$(bytes_of "$TYPE_BAD_U64_TO_PTR_SRC")"
log "type.bad.load.u8.source.path=$TYPE_BAD_LOAD_U8_SRC"
log "type.bad.load.u8.source.bytes=$(bytes_of "$TYPE_BAD_LOAD_U8_SRC")"
log "type.bad.load.u16.source.path=$TYPE_BAD_LOAD_U16_SRC"
log "type.bad.load.u16.source.bytes=$(bytes_of "$TYPE_BAD_LOAD_U16_SRC")"
log "type.bad.load.u32.source.path=$TYPE_BAD_LOAD_U32_SRC"
log "type.bad.load.u32.source.bytes=$(bytes_of "$TYPE_BAD_LOAD_U32_SRC")"
log "type.bad.store.u8.source.path=$TYPE_BAD_STORE_U8_SRC"
log "type.bad.store.u8.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U8_SRC")"
log "type.bad.store.u8.range.source.path=$TYPE_BAD_STORE_U8_RANGE_SRC"
log "type.bad.store.u8.range.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U8_RANGE_SRC")"
log "type.bad.store.u16.source.path=$TYPE_BAD_STORE_U16_SRC"
log "type.bad.store.u16.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U16_SRC")"
log "type.bad.store.u16.range.source.path=$TYPE_BAD_STORE_U16_RANGE_SRC"
log "type.bad.store.u16.range.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U16_RANGE_SRC")"
log "type.bad.store.u32.source.path=$TYPE_BAD_STORE_U32_SRC"
log "type.bad.store.u32.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U32_SRC")"
log "type.bad.store.u32.range.source.path=$TYPE_BAD_STORE_U32_RANGE_SRC"
log "type.bad.store.u32.range.source.bytes=$(bytes_of "$TYPE_BAD_STORE_U32_RANGE_SRC")"
log "type.bad.branch.source.path=$TYPE_BAD_BRANCH_SRC"
log "type.bad.branch.source.bytes=$(bytes_of "$TYPE_BAD_BRANCH_SRC")"
log "type.bad.expect.ptr.source.path=$TYPE_BAD_EXPECT_PTR_SRC"
log "type.bad.expect.ptr.source.bytes=$(bytes_of "$TYPE_BAD_EXPECT_PTR_SRC")"
log "bootstrap.source.path=$BOOTSTRAP_SRC"
log "bootstrap.source.bytes=$(bytes_of "$BOOTSTRAP_SRC")"
log "bootstrap.aot.source.path=$BOOTSTRAP_AOT_SRC"
log "bootstrap.aot.source.bytes=$(bytes_of "$BOOTSTRAP_AOT_SRC")"
log "bootstrap.abi.source.path=$BOOTSTRAP_ABI_SRC"
log "bootstrap.abi.source.bytes=$(bytes_of "$BOOTSTRAP_ABI_SRC")"
log "bootstrap.ape.source.path=$BOOTSTRAP_APE_SRC"
log "bootstrap.ape.source.bytes=$(bytes_of "$BOOTSTRAP_APE_SRC")"
log "bootstrap.v25.native.selfpack.source.path=$BOOTSTRAP_V25_NATIVE_SELFPACK_SRC"
log "bootstrap.v25.native.selfpack.source.bytes=$(bytes_of "$BOOTSTRAP_V25_NATIVE_SELFPACK_SRC")"
log "smoke.source.path=$SMOKE_SRC"
log "smoke.source.bytes=$(bytes_of "$SMOKE_SRC")"
log "native.runtime.bytes=$(bytes_of "$RUNNER")"

run_case "compile-lisp-to-lbin" "$RUNNER" compile "$SRC" "$BLOB"
log "blob.bytes=$(bytes_of "$BLOB")"

run_case "compile-lisp-to-lbin-repeat" "$RUNNER" compile "$SRC" "$BLOB_REPEAT"
log "blob.repeat.bytes=$(bytes_of "$BLOB_REPEAT")"

run_case "hash-lbin" "$RUNNER" hash "$BLOB"

run_case "hash-lbin-repeat" "$RUNNER" hash "$BLOB_REPEAT"

run_case "compare-deterministic-lbin" "$RUNNER" compare "$BLOB" "$BLOB_REPEAT"

run_case "execute-lbin-via-jit" "$RUNNER" run "$BLOB"

run_case "compile-arithmetic-lbin" "$RUNNER" compile "$ARITH_SRC" "$ARITH_BLOB"
log "arithmetic.blob.bytes=$(bytes_of "$ARITH_BLOB")"

run_case "hash-arithmetic-lbin" "$RUNNER" hash "$ARITH_BLOB"

run_case "execute-arithmetic-lbin" "$RUNNER" run "$ARITH_BLOB"

run_case "compile-arithmetic-i64-lbin" "$RUNNER" compile "$ARITH_I64_SRC" "$ARITH_I64_BLOB"
log "arithmetic.i64.blob.bytes=$(bytes_of "$ARITH_I64_BLOB")"

run_case "execute-arithmetic-i64-lbin" "$RUNNER" run "$ARITH_I64_BLOB"

run_case "compile-func-param-vm-parity-lbin" "$RUNNER" compile "$FUNC_PARAM_VM_PARITY_SRC" "$FUNC_PARAM_VM_PARITY_BLOB"
run_case "run-func-param-vm-parity-lbin-expect42" "$RUNNER" run "$FUNC_PARAM_VM_PARITY_BLOB"

run_case "compile-func-call-vm-smoke-lbin" "$RUNNER" compile "$FUNC_CALL_VM_SMOKE_SRC" "$FUNC_CALL_VM_SMOKE_BLOB"
run_case "run-func-call-vm-smoke-lbin-expect42" "$RUNNER" run "$FUNC_CALL_VM_SMOKE_BLOB"

run_case "compile-func-param-vm-i64-lbin" "$RUNNER" compile "$FUNC_PARAM_VM_I64_SRC" "$FUNC_PARAM_VM_I64_BLOB"
run_case "run-func-param-vm-i64-lbin-expect42" "$RUNNER" run "$FUNC_PARAM_VM_I64_BLOB"

run_case "compile-typed-values-lbin" "$RUNNER" compile "$TYPED_SRC" "$TYPED_BLOB"
log "typed.blob.bytes=$(bytes_of "$TYPED_BLOB")"

run_case "execute-typed-values-lbin" "$RUNNER" run "$TYPED_BLOB"

run_case "compile-ptr-values-lbin" "$RUNNER" compile "$PTR_SRC" "$PTR_BLOB"
log "ptr.blob.bytes=$(bytes_of "$PTR_BLOB")"

run_case "execute-ptr-values-lbin" "$RUNNER" run "$PTR_BLOB"

run_case "compile-const-ptr-load-u8-lbin" "$RUNNER" compile "$CONST_PTR_SRC" "$CONST_PTR_BLOB"
log "const.ptr.blob.bytes=$(bytes_of "$CONST_PTR_BLOB")"

run_case "execute-const-ptr-load-u8-lbin" "$RUNNER" run "$CONST_PTR_BLOB"

run_case "run-bootstrap-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_SRC"

run_case "run-bootstrap-aot-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_AOT_SRC"

run_case "run-bootstrap-abi-smoke-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_ABI_SRC"

run_case "run-bootstrap-ape-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_APE_SRC"

if [ -f "$APE_COM" ]; then
  run_case "make-ape-negative-fixtures" python3 "$LAB_DIR/make_ape_fixtures.py" "$APE_COM" "$BUILD_DIR"
  run_case "run-bootstrap-ape-negative-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_APE_NEG_SRC"
  if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ]; then
    run_case "run-ape-native-exit42" "$RUNNER" run-ape-expect-exit "$APE_COM" 42
    run_case "compile-const-ptr-elf64-code-ape-evidence" "$RUNNER" compile-elf64-code "$CONST_PTR_SRC" "$CONST_PTR_DIRECT_EXE"
    run_case "run-const-ptr-elf64-code-ape-evidence" "$RUNNER" run-expect-exit "$CONST_PTR_DIRECT_EXE" 1
  fi
  if has_qemu_aarch64 && [ -f "$NANO_JIT_COM" ]; then
    run_case "run-ape-aarch64-nano-jit-com" bash -c '
      out=$("'"$RUNNER"'" run-ape "'"$NANO_JIT_COM"'" aarch64 2>&1) || true
      printf "%s\n" "$out"
      printf "%s\n" "$out" | grep -q "run-ape.force_arch=aarch64"
    '
  elif has_qemu_aarch64; then
    skip_case "run-ape-aarch64-nano-jit-com" "nano-jit.com missing (run build_nano_jit.sh first)"
  else
    skip_case "run-ape-aarch64" "no qemu-aarch64-static or qemu-aarch64"
  fi
fi

# --- bootstrap-ape-v2 (binary header at payload marker) ---
BOOTSTRAP_APE_V2_SRC="$LAB_DIR/samples/bootstrap-ape-v2-smoke.lisp"
APE_V2_COM="$BUILD_DIR/bootstrap-ape-v2.com"
log "bootstrap.ape.v2.source.path=$BOOTSTRAP_APE_V2_SRC"
log "bootstrap.ape.v2.source.bytes=$(bytes_of "$BOOTSTRAP_APE_V2_SRC")"
run_case "run-bootstrap-ape-v2-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_APE_V2_SRC"
if [ -f "$APE_V2_COM" ]; then
  run_case "pack-ape-v2-fixture" test -f "$APE_V2_COM"
  run_case "inspect-ape-v2-container" bash -c '
    out=$("'"$RUNNER"'" inspect-ape "'"$APE_V2_COM"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "inspect-ape.container=ape-v2"
  '
  if host_is_linux_x86_64; then
    run_case "run-ape-v2-native-exit42" "$RUNNER" run-ape-expect-exit "$APE_V2_COM" 42
    run_case "run-ape-v2-memfd-loader-smoke" bash -c '
      out=$("'"$RUNNER"'" run-ape "'"$APE_V2_COM"'" 2>&1) || true
      printf "%s\n" "$out"
      printf "%s\n" "$out" | grep -q "run-ape.container=ape-v2"
      printf "%s\n" "$out" | grep -q "run-ape.loader=memfd"
      printf "%s\n" "$out" | grep -q "run-ape.exit=42"
    '
  else
    skip_case "run-ape-v2-native-exit42" "host is not Linux x86_64 (uname -s=$(uname -s) -m=$(uname -m))"
    skip_case "run-ape-v2-memfd-loader-smoke" "host is not Linux x86_64 (uname -s=$(uname -s) -m=$(uname -m))"
  fi
  APE_V2_BARE_COM="$BUILD_DIR/bootstrap-ape-v2-bare.com"
  if [ -f "$APE_V2_BARE_COM" ]; then
    run_case "inspect-ape-bare-v2" bash -c '
      out=$("'"$RUNNER"'" inspect-ape "'"$APE_V2_BARE_COM"'" 2>&1) || true
      printf "%s\n" "$out"
      printf "%s\n" "$out" | grep -q "inspect-ape.container=ape-v2"
    '
    if host_is_linux_x86_64; then
      run_case "run-ape-bare-v2-exit42" "$RUNNER" run-ape-expect-exit "$APE_V2_BARE_COM" 42
      run_case "run-ape-bare-v2-memfd-loader-smoke" bash -c '
        out=$("'"$RUNNER"'" run-ape "'"$APE_V2_BARE_COM"'" 2>&1) || true
        printf "%s\n" "$out"
        printf "%s\n" "$out" | grep -q "run-ape.container=ape-v2"
        printf "%s\n" "$out" | grep -q "run-ape.loader=memfd"
        printf "%s\n" "$out" | grep -q "run-ape.exit=42"
      '
    else
      skip_case "run-ape-bare-v2-exit42" "host is not Linux x86_64 (uname -s=$(uname -s) -m=$(uname -m))"
      skip_case "run-ape-bare-v2-memfd-loader-smoke" "host is not Linux x86_64 (uname -s=$(uname -s) -m=$(uname -m))"
    fi
  else
    skip_case "inspect-ape-bare-v2" "bootstrap-ape-v2-bare.com missing after plan"
    skip_case "run-ape-bare-v2-exit42" "bootstrap-ape-v2-bare.com missing after plan"
    skip_case "run-ape-bare-v2-memfd-loader-smoke" "bootstrap-ape-v2-bare.com missing after plan"
  fi
  APE_V2_X86_ELF="$BUILD_DIR/bootstrap-ape-v2-x86.elf"
  APE_V2_ARM_ELF="$BUILD_DIR/bootstrap-ape-v2-arm.elf"
  PACK_APE_V25_BARE_ENV_COM="$BUILD_DIR/pack-ape-v25-bare-env.com"
  if [ -f "$APE_V2_X86_ELF" ] && [ -f "$APE_V2_ARM_ELF" ]; then
    run_case "pack-ape-v25-bare-mode-env" bash -c '
      export NANO_PACK_APE_MODE=bare
      out=$("'"$RUNNER"'" pack-ape "'"$PACK_APE_V25_BARE_ENV_COM"'" \
        "'"$APE_V2_X86_ELF"'" "'"$APE_V2_ARM_ELF"'" 2>&1) || true
      printf "%s\n" "$out"
      printf "%s\n" "$out" | grep -q "pack-ape-bare.mode=bare"
      test -f "'"$PACK_APE_V25_BARE_ENV_COM"'"
      inspect=$("'"$RUNNER"'" inspect-ape "'"$PACK_APE_V25_BARE_ENV_COM"'" 2>&1) || true
      printf "%s\n" "$inspect"
      printf "%s\n" "$inspect" | grep -q "inspect-ape.container=ape-v2"
    '
    if host_is_linux_x86_64; then
      run_case "run-ape-v25-bare-mode-env-exit42" \
        "$RUNNER" run-ape-expect-exit "$PACK_APE_V25_BARE_ENV_COM" 42
    else
      skip_case "run-ape-v25-bare-mode-env-exit42" "host is not Linux x86_64"
    fi
  else
    skip_case "pack-ape-v25-bare-mode-env" "bootstrap-ape-v2 slice ELFs missing"
    skip_case "run-ape-v25-bare-mode-env-exit42" "bootstrap-ape-v2 slice ELFs missing"
  fi
  run_case "make-ape-v2-negative-fixtures" python3 "$LAB_DIR/make_ape_fixtures.py" "$APE_V2_COM" "$BUILD_DIR"
  if [ -f "$BUILD_DIR/ape-v2-bare.com" ]; then
    run_case "inspect-ape-v2-bare-fixture" bash -c '
      out=$("'"$RUNNER"'" inspect-ape "'"$BUILD_DIR/ape-v2-bare.com"'" 2>&1) || true
      printf "%s\n" "$out"
      printf "%s\n" "$out" | grep -q "inspect-ape.container=ape-v2"
    '
    if host_is_linux_x86_64; then
      run_case "run-ape-v2-bare-fixture-exit42" "$RUNNER" run-ape-expect-exit "$BUILD_DIR/ape-v2-bare.com" 42
    else
      skip_case "run-ape-v2-bare-fixture-exit42" "host is not Linux x86_64"
    fi
  fi
  BOOTSTRAP_APE_V2_NEG_SRC="$LAB_DIR/samples/bootstrap-ape-v2-negative.lisp"
  run_case "run-bootstrap-ape-v2-negative-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_APE_V2_NEG_SRC"
else
  skip_case "pack-ape-v2-fixture" "bootstrap-ape-v2.com missing after plan"
  skip_case "inspect-ape-v2-container" "bootstrap-ape-v2.com missing after plan"
  skip_case "run-ape-v2-native-exit42" "bootstrap-ape-v2.com missing after plan"
fi

if [ -f "$BUILD_DIR/ape-v1-legacy.com" ]; then
  run_case "inspect-ape-v1-legacy-fallback" bash -c '
    out=$("'"$RUNNER"'" inspect-ape "'"$BUILD_DIR/ape-v1-legacy.com"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "inspect-ape.container=ape-v1"
  '
  if host_is_linux_x86_64; then
    run_case "run-ape-v1-legacy-memfd-loader-smoke" bash -c '
      out=$("'"$RUNNER"'" run-ape "'"$BUILD_DIR/ape-v1-legacy.com"'" 2>&1) || true
      printf "%s\n" "$out"
      printf "%s\n" "$out" | grep -q "run-ape.loader=memfd"
      printf "%s\n" "$out" | grep -q "run-ape.exit=42"
    '
  else
    skip_case "run-ape-v1-legacy-memfd-loader-smoke" "host is not Linux x86_64 (uname -s=$(uname -s) -m=$(uname -m))"
  fi
fi

run_case "compile-control-flow-lbin" "$RUNNER" compile "$CTRL_SRC" "$CTRL_BLOB"
log "control.blob.bytes=$(bytes_of "$CTRL_BLOB")"

run_case "execute-control-flow-lbin" "$RUNNER" run "$CTRL_BLOB"

if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ]; then
  run_case "emit-elf64-exit42" "$RUNNER" emit-elf64-exit "$EXIT42" 42
  log "exit42.bytes=$(bytes_of "$EXIT42")"
  run_case "run-elf64-exit42" "$RUNNER" run-expect-exit "$EXIT42" 42
  run_case "aot-arithmetic-elf64-exit42" "$RUNNER" aot-elf64-exit "$ARITH_BLOB" "$ARITH_EXIT"
  log "arithmetic.aot.bytes=$(bytes_of "$ARITH_EXIT")"
  run_case "run-aot-arithmetic-exit42" "$RUNNER" run-expect-exit "$ARITH_EXIT" 42
  run_case "aot-arithmetic-elf64-code42" "$RUNNER" aot-elf64-code "$ARITH_BLOB" "$ARITH_CODE"
  log "arithmetic.codegen.bytes=$(bytes_of "$ARITH_CODE")"
  run_case "run-aot-arithmetic-code42" "$RUNNER" run-expect-exit "$ARITH_CODE" 42
  run_case "aot-arithmetic-i64-elf64-code42" "$RUNNER" aot-elf64-code "$ARITH_I64_BLOB" "$ARITH_I64_CODE"
  run_case "run-aot-arithmetic-i64-code42" "$RUNNER" run-expect-exit "$ARITH_I64_CODE" 42
  run_case "compile-bad-arithmetic-lbin" "$RUNNER" compile "$BAD_ARITH_SRC" "$BAD_ARITH_BLOB"
  run_case "aot-bad-arithmetic-elf64-code" "$RUNNER" aot-elf64-code "$BAD_ARITH_BLOB" "$BAD_ARITH_CODE"
  run_case "run-aot-bad-arithmetic-expect125" "$RUNNER" run-expect-exit "$BAD_ARITH_CODE" 125
  run_case "aot-control-flow-elf64-exit1" "$RUNNER" aot-elf64-exit "$CTRL_BLOB" "$CTRL_EXIT"
  run_case "run-aot-control-flow-exit1" "$RUNNER" run-expect-exit "$CTRL_EXIT" 1
  run_case "aot-ptr-values-elf64-exit1" "$RUNNER" aot-elf64-exit "$PTR_BLOB" "$PTR_EXIT"
  run_case "run-aot-ptr-values-exit1" "$RUNNER" run-expect-exit "$PTR_EXIT" 1
  run_case "aot-const-ptr-load-u8-elf64-exit1" "$RUNNER" aot-elf64-exit "$CONST_PTR_BLOB" "$CONST_PTR_EXIT"
  run_case "run-aot-const-ptr-load-u8-exit1" "$RUNNER" run-expect-exit "$CONST_PTR_EXIT" 1
  run_case "aot-const-ptr-load-u8-elf64-code1" "$RUNNER" aot-elf64-code "$CONST_PTR_BLOB" "$CONST_PTR_CODE"
  run_case "run-aot-const-ptr-load-u8-code1" "$RUNNER" run-expect-exit "$CONST_PTR_CODE" 1
  run_case "aot-const-ptr-load-u8-elf64-obj-code1" "$RUNNER" aot-elf64-obj-code "$CONST_PTR_BLOB" "$CONST_PTR_CODE_OBJ" nano_const_ptr_code
  run_case "tiny-link-aot-const-ptr-load-u8-obj-code1" "$RUNNER" link-elf64-exe "$CONST_PTR_LINK_EXE" nano_const_ptr_code "$CONST_PTR_CODE_OBJ"
  run_case "run-tiny-linked-const-ptr-load-u8-1" "$RUNNER" run-expect-exit "$CONST_PTR_LINK_EXE" 1
  run_case "emit-cross-object-const-ptr-call" "$RUNNER" emit-elf64-obj-call "$CONST_PTR_CALL_OBJ" nano_const_ptr_call nano_const_ptr_callee
  run_case "aot-cross-object-const-ptr-callee" "$RUNNER" aot-elf64-obj-code "$CONST_PTR_BLOB" "$CONST_PTR_CALLEE_OBJ" nano_const_ptr_callee
  run_case "tiny-link-cross-object-const-ptr-data" "$RUNNER" link-elf64-exe "$CONST_PTR_CROSS_LINK_EXE" nano_const_ptr_call "$CONST_PTR_CALL_OBJ" "$CONST_PTR_CALLEE_OBJ"
  run_case "run-cross-object-const-ptr-data" "$RUNNER" run-expect-exit "$CONST_PTR_CROSS_LINK_EXE" 1
  run_case "aot-ptr-values-elf64-code1" "$RUNNER" aot-elf64-code "$PTR_BLOB" "$PTR_CODE"
  run_case "run-aot-ptr-values-code1" "$RUNNER" run-expect-exit "$PTR_CODE" 1
  run_case "aot-ptr-values-elf64-obj-code1" "$RUNNER" aot-elf64-obj-code "$PTR_BLOB" "$PTR_CODE_OBJ" nano_ptr_code
  run_case "tiny-link-aot-ptr-values-obj-code1" "$RUNNER" link-elf64-exe "$PTR_LINK_EXE" nano_ptr_code "$PTR_CODE_OBJ"
  run_case "run-tiny-linked-ptr-values1" "$RUNNER" run-expect-exit "$PTR_LINK_EXE" 1
  run_case "aot-control-flow-elf64-obj-ret1" "$RUNNER" aot-elf64-obj-ret "$CTRL_BLOB" "$CTRL_OBJ" nano_ctrl
  run_case "link-aot-control-flow-obj1" "$RUNNER" link-elf64-exe "$CTRL_OBJ_EXE" nano_ctrl "$CTRL_OBJ"
  run_case "run-aot-control-flow-obj1" "$RUNNER" run-expect-exit "$CTRL_OBJ_EXE" 1
  run_case "aot-control-flow-elf64-code1" "$RUNNER" aot-elf64-code "$CTRL_BLOB" "$CTRL_CODE"
  run_case "run-aot-control-flow-code1" "$RUNNER" run-expect-exit "$CTRL_CODE" 1
  run_case "aot-control-flow-elf64-obj-code1" "$RUNNER" aot-elf64-obj-code "$CTRL_BLOB" "$CTRL_CODE_OBJ" nano_ctrl_code
  run_case "tiny-link-aot-control-flow-obj-code1" "$RUNNER" link-elf64-exe "$CTRL_LINK_EXE" nano_ctrl_code "$CTRL_CODE_OBJ"
  run_case "run-tiny-linked-control-flow1" "$RUNNER" run-expect-exit "$CTRL_LINK_EXE" 1
  run_case "compile-control-flow-elf64-code1" "$RUNNER" compile-elf64-code "$CTRL_SRC" "$CTRL_DIRECT_EXE"
  run_case "run-direct-compiled-control-flow1" "$RUNNER" run-expect-exit "$CTRL_DIRECT_EXE" 1
  run_case "compile-ptr-values-elf64-code1" "$RUNNER" compile-elf64-code "$PTR_SRC" "$PTR_DIRECT_EXE"
  run_case "run-direct-compiled-ptr-values1" "$RUNNER" run-expect-exit "$PTR_DIRECT_EXE" 1
  run_case "compile-const-ptr-load-u8-elf64-code1" "$RUNNER" compile-elf64-code "$CONST_PTR_SRC" "$CONST_PTR_DIRECT_EXE"
  run_case "run-direct-compiled-const-ptr-load-u8-1" "$RUNNER" run-expect-exit "$CONST_PTR_DIRECT_EXE" 1
  run_case "compile-rodata-readonly-elf64-code0" "$RUNNER" compile-elf64-code "$RODATA_READONLY_SRC" "$RODATA_READONLY_EXE"
  run_case "run-direct-compiled-rodata-readonly-0" "$RUNNER" run-expect-exit "$RODATA_READONLY_EXE" 0
  run_case "emit-elf64-obj-ret42" "$RUNNER" emit-elf64-obj-ret "$RET42_OBJ" nano_ret 42
  log "ret42.obj.bytes=$(bytes_of "$RET42_OBJ")"
  run_case "link-elf64-obj-ret42" "$RUNNER" link-elf64-exe "$RET42_EXE" nano_ret "$RET42_OBJ"
  run_case "run-elf64-obj-ret42" "$RUNNER" run-expect-exit "$RET42_EXE" 42
  run_case "aot-arithmetic-elf64-obj-ret42" "$RUNNER" aot-elf64-obj-ret "$ARITH_BLOB" "$ARITH_OBJ" nano_arith
  log "arithmetic.obj.bytes=$(bytes_of "$ARITH_OBJ")"
  run_case "link-aot-arithmetic-obj-ret42" "$RUNNER" link-elf64-exe "$ARITH_OBJ_EXE" nano_arith "$ARITH_OBJ"
  run_case "run-aot-arithmetic-obj-ret42" "$RUNNER" run-expect-exit "$ARITH_OBJ_EXE" 42
  run_case "aot-arithmetic-elf64-obj-code42" "$RUNNER" aot-elf64-obj-code "$ARITH_BLOB" "$ARITH_CODE_OBJ" nano_arith_code
  log "arithmetic.code.obj.bytes=$(bytes_of "$ARITH_CODE_OBJ")"
  run_case "tiny-link-aot-arithmetic-obj-code42" "$RUNNER" link-elf64-exe "$ARITH_LINK_EXE" nano_arith_code "$ARITH_CODE_OBJ"
  log "arithmetic.tiny.link.bytes=$(bytes_of "$ARITH_LINK_EXE")"
  run_case "run-tiny-linked-arithmetic42" "$RUNNER" run-expect-exit "$ARITH_LINK_EXE" 42
  run_case "aot-arithmetic-i64-elf64-obj-code42" "$RUNNER" aot-elf64-obj-code "$ARITH_I64_BLOB" "$ARITH_I64_CODE_OBJ" nano_arith_i64_code
  run_case "tiny-link-aot-arithmetic-i64-obj-code42" "$RUNNER" link-elf64-exe "$ARITH_I64_LINK_EXE" nano_arith_i64_code "$ARITH_I64_CODE_OBJ"
  run_case "run-tiny-linked-arithmetic-i64-42" "$RUNNER" run-expect-exit "$ARITH_I64_LINK_EXE" 42
  run_case "compile-arithmetic-elf64-code42" "$RUNNER" compile-elf64-code "$ARITH_SRC" "$ARITH_DIRECT_EXE"
  log "arithmetic.direct.bytes=$(bytes_of "$ARITH_DIRECT_EXE")"
  run_case "run-direct-compiled-arithmetic42" "$RUNNER" run-expect-exit "$ARITH_DIRECT_EXE" 42
  run_case "compile-arithmetic-i64-elf64-code42" "$RUNNER" compile-elf64-code "$ARITH_I64_SRC" "$ARITH_I64_DIRECT_EXE"
  run_case "run-direct-compiled-arithmetic-i64-42" "$RUNNER" run-expect-exit "$ARITH_I64_DIRECT_EXE" 42
  run_case "compile-arithmetic-i64-elf64-obj-code42" "$RUNNER" compile-elf64-obj-code "$ARITH_I64_SRC" "$ARITH_I64_DIRECT_OBJ" nano_arith_i64_direct
  run_case "tiny-link-direct-compiled-arithmetic-i64-obj42" "$RUNNER" link-elf64-exe "$ARITH_I64_DIRECT_LINK_EXE" nano_arith_i64_direct "$ARITH_I64_DIRECT_OBJ"
  run_case "run-tiny-linked-direct-arithmetic-i64-obj42" "$RUNNER" run-expect-exit "$ARITH_I64_DIRECT_LINK_EXE" 42
  run_case "compile-arithmetic-elf64-obj-code42" "$RUNNER" compile-elf64-obj-code "$ARITH_SRC" "$ARITH_DIRECT_OBJ" nano_arith_direct
  run_case "link-direct-compiled-arithmetic-obj42" "$RUNNER" link-elf64-exe "$ARITH_DIRECT_OBJ_EXE" nano_arith_direct "$ARITH_DIRECT_OBJ"
  run_case "run-direct-compiled-arithmetic-obj42" "$RUNNER" run-expect-exit "$ARITH_DIRECT_OBJ_EXE" 42
  run_case "compile-multi-func-elf64-obj43" "$RUNNER" compile-elf64-obj-code "$MULTI_SRC" "$MULTI_OBJ" nano_multi_entry
  log "multi.obj.bytes=$(bytes_of "$MULTI_OBJ")"
  run_case "tiny-link-multi-func-obj43" "$RUNNER" link-elf64-exe "$MULTI_LINK_EXE" nano_multi_entry "$MULTI_OBJ"
  log "multi.tiny.link.bytes=$(bytes_of "$MULTI_LINK_EXE")"
  run_case "run-tiny-linked-multi-func43" "$RUNNER" run-expect-exit "$MULTI_LINK_EXE" 43
  run_case "compile-multi-func-control-flow-elf64-obj43" "$RUNNER" compile-elf64-obj-code "$MULTI_CTRL_SRC" "$MULTI_CTRL_OBJ" nano_multi_ctrl
  log "multi.ctrl.obj.bytes=$(bytes_of "$MULTI_CTRL_OBJ")"
  run_case "tiny-link-multi-func-control-flow-obj43" "$RUNNER" link-elf64-exe "$MULTI_CTRL_LINK_EXE" nano_multi_ctrl "$MULTI_CTRL_OBJ"
  log "multi.ctrl.tiny.link.bytes=$(bytes_of "$MULTI_CTRL_LINK_EXE")"
  run_case "run-tiny-linked-multi-func-control-flow43" "$RUNNER" run-expect-exit "$MULTI_CTRL_LINK_EXE" 43
  run_case "compile-multi-func-ptr-elf64-obj1" "$RUNNER" compile-elf64-obj-code "$MULTI_PTR_SRC" "$MULTI_PTR_OBJ" nano_multi_ptr
  run_case "tiny-link-multi-func-ptr-obj1" "$RUNNER" link-elf64-exe "$MULTI_PTR_LINK_EXE" nano_multi_ptr "$MULTI_PTR_OBJ"
  run_case "run-tiny-linked-multi-func-ptr1" "$RUNNER" run-expect-exit "$MULTI_PTR_LINK_EXE" 1
  run_case "compile-multi-func-ptr-elf64-exe1" "$RUNNER" compile-elf64-exe "$MULTI_PTR_SRC" "$MULTI_PTR_DIRECT_EXE" nano_multi_ptr_direct
  run_case "run-direct-compiled-multi-func-ptr1" "$RUNNER" run-expect-exit "$MULTI_PTR_DIRECT_EXE" 1
  run_case "compile-func-param-i64-elf64-exe42" "$RUNNER" compile-elf64-exe "$FUNC_PARAM_I64_SRC" "$FUNC_PARAM_I64_EXE" nano_func_param
  run_case "run-direct-compiled-func-param-i64-42" "$RUNNER" run-expect-exit "$FUNC_PARAM_I64_EXE" 42
  run_case "reject-func-param-missing-param-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$FUNC_PARAM_MISSING_PARAM_BAD_SRC" "$FUNC_PARAM_MISSING_PARAM_BAD_OBJ" nano_func_param_missing_param_bad
  run_case "reject-func-param-missing-param-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$FUNC_PARAM_MISSING_PARAM_BAD_SRC" "$FUNC_PARAM_MISSING_PARAM_BAD_EXE" nano_func_param_missing_param_bad
  run_case "reject-func-param-call-no-arg-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$FUNC_PARAM_CALL_NO_ARG_BAD_SRC" "$FUNC_PARAM_CALL_NO_ARG_BAD_OBJ" nano_func_param_call_no_arg_bad
  run_case "reject-func-param-call-no-arg-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$FUNC_PARAM_CALL_NO_ARG_BAD_SRC" "$FUNC_PARAM_CALL_NO_ARG_BAD_EXE" nano_func_param_call_no_arg_bad
  run_case "reject-func-param-missing-param-vm-lbin" "$RUNNER" compile-expect-exit 2 compile "$FUNC_PARAM_MISSING_PARAM_BAD_SRC" "$FUNC_PARAM_MISSING_PARAM_BAD_LBIN"
  run_case "reject-func-param-call-no-arg-vm-lbin" "$RUNNER" compile-expect-exit 2 compile "$FUNC_PARAM_CALL_NO_ARG_BAD_SRC" "$FUNC_PARAM_CALL_NO_ARG_BAD_LBIN"
  run_case "reject-ptr-op-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_PTR_OP_SRC" "$TYPE_BAD_PTR_OP_EXE"
  run_case "reject-ptr-op-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_PTR_OP_SRC" "$TYPE_BAD_PTR_OP_OBJ" nano_type_bad_ptr_op
  run_case "reject-ptr-op-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_PTR_OP_SRC" "$TYPE_BAD_PTR_OP_EXE" nano_type_bad_ptr_op
  run_case "reject-add-ptr-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_ADD_PTR_SRC" "$TYPE_BAD_ADD_PTR_OBJ" nano_type_bad_add_ptr
  run_case "reject-sub-ptr-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_SUB_PTR_SRC" "$TYPE_BAD_SUB_PTR_OBJ" nano_type_bad_sub_ptr
  run_case "reject-ptr-to-u64-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_PTR_TO_U64_SRC" "$TYPE_BAD_PTR_TO_U64_EXE"
  run_case "reject-ptr-to-u64-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_PTR_TO_U64_SRC" "$TYPE_BAD_PTR_TO_U64_OBJ" nano_type_bad_ptr_to_u64
  run_case "reject-ptr-to-u64-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_PTR_TO_U64_SRC" "$TYPE_BAD_PTR_TO_U64_EXE" nano_type_bad_ptr_to_u64
  run_case "reject-u64-to-ptr-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_U64_TO_PTR_SRC" "$TYPE_BAD_U64_TO_PTR_EXE"
  run_case "reject-u64-to-ptr-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_U64_TO_PTR_SRC" "$TYPE_BAD_U64_TO_PTR_OBJ" nano_type_bad_u64_to_ptr
  run_case "reject-u64-to-ptr-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_U64_TO_PTR_SRC" "$TYPE_BAD_U64_TO_PTR_EXE" nano_type_bad_u64_to_ptr
  run_case "reject-load-u8-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_LOAD_U8_SRC" "$TYPE_BAD_LOAD_U8_EXE"
  run_case "reject-load-u8-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_LOAD_U8_SRC" "$TYPE_BAD_LOAD_U8_OBJ" nano_type_bad_load_u8
  run_case "reject-load-u8-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_LOAD_U8_SRC" "$TYPE_BAD_LOAD_U8_EXE" nano_type_bad_load_u8
  run_case "reject-load-u16-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_LOAD_U16_SRC" "$TYPE_BAD_LOAD_U16_EXE"
  run_case "reject-load-u16-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_LOAD_U16_SRC" "$TYPE_BAD_LOAD_U16_OBJ" nano_type_bad_load_u16
  run_case "reject-load-u16-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_LOAD_U16_SRC" "$TYPE_BAD_LOAD_U16_EXE" nano_type_bad_load_u16
  run_case "reject-load-u32-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_LOAD_U32_SRC" "$TYPE_BAD_LOAD_U32_EXE"
  run_case "reject-load-u32-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_LOAD_U32_SRC" "$TYPE_BAD_LOAD_U32_OBJ" nano_type_bad_load_u32
  run_case "reject-load-u32-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_LOAD_U32_SRC" "$TYPE_BAD_LOAD_U32_EXE" nano_type_bad_load_u32
  run_case "reject-store-u8-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U8_SRC" "$TYPE_BAD_STORE_U8_EXE"
  run_case "reject-store-u8-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U8_SRC" "$TYPE_BAD_STORE_U8_OBJ" nano_type_bad_store_u8
  run_case "reject-store-u8-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U8_SRC" "$TYPE_BAD_STORE_U8_EXE" nano_type_bad_store_u8
  run_case "reject-store-u8-range-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U8_RANGE_SRC" "$TYPE_BAD_STORE_U8_RANGE_EXE"
  run_case "reject-store-u8-range-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U8_RANGE_SRC" "$TYPE_BAD_STORE_U8_RANGE_OBJ" nano_type_bad_store_u8_range
  run_case "reject-store-u8-range-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U8_RANGE_SRC" "$TYPE_BAD_STORE_U8_RANGE_EXE" nano_type_bad_store_u8_range
  run_case "reject-store-u16-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U16_SRC" "$TYPE_BAD_STORE_U16_EXE"
  run_case "reject-store-u16-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U16_SRC" "$TYPE_BAD_STORE_U16_OBJ" nano_type_bad_store_u16
  run_case "reject-store-u16-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U16_SRC" "$TYPE_BAD_STORE_U16_EXE" nano_type_bad_store_u16
  run_case "reject-store-u16-range-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U16_RANGE_SRC" "$TYPE_BAD_STORE_U16_RANGE_EXE"
  run_case "reject-store-u16-range-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U16_RANGE_SRC" "$TYPE_BAD_STORE_U16_RANGE_OBJ" nano_type_bad_store_u16_range
  run_case "reject-store-u16-range-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U16_RANGE_SRC" "$TYPE_BAD_STORE_U16_RANGE_EXE" nano_type_bad_store_u16_range
  run_case "reject-store-u32-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U32_SRC" "$TYPE_BAD_STORE_U32_EXE"
  run_case "reject-store-u32-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U32_SRC" "$TYPE_BAD_STORE_U32_OBJ" nano_type_bad_store_u32
  run_case "reject-store-u32-type-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U32_SRC" "$TYPE_BAD_STORE_U32_EXE" nano_type_bad_store_u32
  run_case "reject-store-u32-range-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_STORE_U32_RANGE_SRC" "$TYPE_BAD_STORE_U32_RANGE_EXE"
  run_case "reject-store-u32-range-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_STORE_U32_RANGE_SRC" "$TYPE_BAD_STORE_U32_RANGE_OBJ" nano_type_bad_store_u32_range
  run_case "reject-store-u32-range-error-elf64-exe" "$RUNNER" compile-expect-exit 2 compile-elf64-exe "$TYPE_BAD_STORE_U32_RANGE_SRC" "$TYPE_BAD_STORE_U32_RANGE_EXE" nano_type_bad_store_u32_range
  run_case "reject-branch-type-error-elf64-code" "$RUNNER" compile-expect-exit 2 compile-elf64-code "$TYPE_BAD_BRANCH_SRC" "$TYPE_BAD_BRANCH_EXE"
  run_case "reject-expect-ptr-type-error-elf64-obj" "$RUNNER" compile-expect-exit 2 compile-elf64-obj-code "$TYPE_BAD_EXPECT_PTR_SRC" "$TYPE_BAD_EXPECT_PTR_OBJ" nano_type_bad_expect_ptr
  run_case "emit-elf64-obj-call42" "$RUNNER" emit-elf64-obj-call "$CALL42_OBJ" nano_call nano_ext
  log "call42.obj.bytes=$(bytes_of "$CALL42_OBJ")"
  run_case "emit-elf64-obj-callee42" "$RUNNER" emit-elf64-obj-ret "$CALL42_CALLEE_OBJ" nano_ext 42
  run_case "tiny-link-elf64-obj-call42" "$RUNNER" link-elf64-exe "$CALL42_LINK_EXE" nano_call "$CALL42_OBJ" "$CALL42_CALLEE_OBJ"
  log "call42.tiny.link.bytes=$(bytes_of "$CALL42_LINK_EXE")"
  run_case "run-tiny-linked-call42" "$RUNNER" run-expect-exit "$CALL42_LINK_EXE" 42
  run_case "aot-const-ptr-data-good-obj" "$RUNNER" aot-elf64-obj-code "$CONST_PTR_BLOB" "$DATA_GOOD_OBJ" nano_main
  run_case "make-data-reloc-negative-fixtures" python3 "$LAB_DIR/make_data_reloc_fixtures.py" "$DATA_GOOD_OBJ" "$DATA_BAD_RELOC_TYPE_OBJ" "$DATA_BAD_RELOC_SYM_OBJ" "$DATA_BAD_SYMBOL_SHNDX_OBJ"
  run_case "tiny-link-reject-bad-data-reloc-type" "$RUNNER" link-expect-exit 4 "$BUILD_DIR/data-bad-reloc-type-fail" nano_main "$DATA_BAD_RELOC_TYPE_OBJ"
  run_case "tiny-link-reject-bad-data-reloc-sym" "$RUNNER" link-expect-exit 4 "$BUILD_DIR/data-bad-reloc-sym-fail" nano_main "$DATA_BAD_RELOC_SYM_OBJ"
  run_case "tiny-link-reject-bad-data-symbol-shndx" "$RUNNER" link-expect-exit 4 "$BUILD_DIR/data-bad-symbol-shndx-fail" nano_main "$DATA_BAD_SYMBOL_SHNDX_OBJ"
  run_case "run-bootstrap-data-negative-plan" "$RUNNER" run-bootstrap-plan "$BOOTSTRAP_DATA_NEG_SRC"
  if [ -f "$NANO_JIT_COM" ]; then
    run_case "run-bootstrap-data-negative-self-pack" \
      bash -c "cd \"$ROOT_DIR\" && \"$NANO_JIT_COM\" run-bootstrap-plan \"$BOOTSTRAP_DATA_NEG_SRC\""
  fi
  run_case "emit-elf64-obj-duplicate-nano-ext" "$RUNNER" emit-elf64-obj-ret "$DUP42_OBJ" nano_ext 7
  run_case "tiny-link-reject-duplicate-symbol" "$RUNNER" link-expect-exit 2 "$BUILD_DIR/dup_should_fail" nano_call "$CALL42_OBJ" "$CALL42_CALLEE_OBJ" "$DUP42_OBJ"
else
  skip_case "run-elf64-exit42" "host is not x86_64"
fi

run_case "compile-libc-smoke-lbin" "$RUNNER" compile "$SMOKE_SRC" "$SMOKE_BLOB"
log "smoke.blob.bytes=$(bytes_of "$SMOKE_BLOB")"

run_case "execute-libc-smoke-lbin" "$RUNNER" run "$SMOKE_BLOB"

run_case "generate-libc-resolve-manifest" "$RUNNER" gen-libc-resolve "$LIBC_SRC"
run_case "compile-libc-resolve-lbin" "$RUNNER" compile "$LIBC_SRC" "$LIBC_BLOB"
log "libc.resolve.blob.bytes=$(bytes_of "$LIBC_BLOB")"
run_case "resolve-libc-imports" "$RUNNER" resolve --quiet "$LIBC_BLOB"

if [ ! -f "$NANO_JIT_COM" ] && host_is_linux_x86_64 && command -v cc >/dev/null 2>&1 && ! cosmocc_available; then
  log ""
  log "# native-slice smoke (cosmocc missing, host cc)"
  NATIVE_SLICE="$NANO_JIT_DIR/nano-jit.x86_64"
  run_case "build-native-x86-slice-via-build-script" \
    env NANO_SLICE_COMPILER=native bash "$LAB_DIR/build_nano_jit.sh"
  if [ -x "$NATIVE_SLICE" ]; then
    run_case "native-x86-slice-compile-strlen" \
      "$NATIVE_SLICE" compile "$SRC" "$BUILD_DIR/native-slice-strlen.lbin"
    run_case "native-x86-slice-run-strlen" \
      "$NATIVE_SLICE" run "$BUILD_DIR/native-slice-strlen.lbin"
  else
    skip_case "native-x86-slice-compile-strlen" "nano-jit.x86_64 missing after build_nano_jit.sh"
    skip_case "native-x86-slice-run-strlen" "nano-jit.x86_64 missing after build_nano_jit.sh"
  fi
fi

# --- build_nano_jit native-slice evidence (v2.5) ---
BOOTSTRAP_REPORT="$NANO_JIT_DIR/bootstrap-report.txt"
if host_is_linux_x86_64 && cosmocc_available; then
  run_case "build-nano-jit-native-smoke" bash -c '
    env NANO_SLICE_COMPILER=native bash "'"$LAB_DIR"'/build_nano_jit.sh"
    grep -q "slice.compiler=native" "'"$BOOTSTRAP_REPORT"'"
    grep "slice.compiler=native" "'"$BOOTSTRAP_REPORT"'"
  '
elif host_is_linux_x86_64; then
  skip_case "build-nano-jit-native-smoke" "cosmocc missing"
else
  skip_case "build-nano-jit-native-smoke" "host is not Linux x86_64 (uname -s=$(uname -s) -m=$(uname -m))"
fi

# --- bootstrap-v3 pack-ape NANO_PACK_APE_MODE=bare (DSL pack-ape-bare-env) ---
V3_PACK_BARE_COM="$BUILD_DIR/bootstrap-v3-pack-bare.com"
log "bootstrap.v3.pack.bare.source.path=$BOOTSTRAP_V3_PACK_BARE_SRC"
run_case "run-bootstrap-v3-pack-bare-plan" bash -c '
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V3_PACK_BARE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=pack-ape-bare-env"
'
if [ -f "$V3_PACK_BARE_COM" ]; then
  run_case "pack-ape-v3-bare-env-output" test -f "$V3_PACK_BARE_COM"
  run_case "inspect-ape-v3-bare-env" bash -c '
    out=$("'"$RUNNER"'" inspect-ape "'"$V3_PACK_BARE_COM"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "inspect-ape.container=ape-v2"
  '
  if host_is_linux_x86_64; then
    run_case "run-ape-v3-bare-env-exit42" "$RUNNER" run-ape-expect-exit "$V3_PACK_BARE_COM" 42
  else
    skip_case "run-ape-v3-bare-env-exit42" "host is not Linux x86_64"
  fi
else
  skip_case "pack-ape-v3-bare-env-output" "bootstrap-v3-pack-bare.com missing after plan"
  skip_case "inspect-ape-v3-bare-env" "bootstrap-v3-pack-bare.com missing after plan"
  skip_case "run-ape-v3-bare-env-exit42" "bootstrap-v3-pack-bare.com missing after plan"
fi

# --- bootstrap-v3 build-graph (slice4 Lisp-orchestrated stage0) ---
log "bootstrap.v3.build.graph.source.path=$BOOTSTRAP_V3_BUILD_GRAPH_SRC"
run_case "run-bootstrap-v3-build-graph-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V3_BUILD_GRAPH_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice"
  h0=$(printf "%s\n" "$out" | grep -E "^[0-9a-f]{16}$" | sed -n "1p")
  h1=$(printf "%s\n" "$out" | grep -E "^[0-9a-f]{16}$" | sed -n "2p")
  printf "graph.x86.hash=%s\n" "$h0"
  printf "graph.aarch64.hash=%s\n" "$h1"
  [ -n "$h0" ] && [ -n "$h1" ] && [ "$h0" != "$h1" ]
'

# --- bootstrap-v3 build-slice plan (slice4 stage0 bridge) ---
log "bootstrap.v3.build.slice.source.path=$BOOTSTRAP_V3_BUILD_SLICE_SRC"
run_case "run-bootstrap-v3-build-slice-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V3_BUILD_SLICE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice"
  printf "%s\n" "$out" | grep -q "build-slice.role=genesis-pin"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=none"
  test -f "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v3-slice-aarch64.elf"
  file -b "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v3-slice-aarch64.elf" | grep -q "ARM aarch64"
'
run_case "verify-genesis-pin-manifest" bash -c '
  test -f "'"$LAB_DIR"'/genesis/nano-jit.x86_64"
  test -f "'"$LAB_DIR"'/genesis/nano-jit.aarch64"
  h0=$("'"$RUNNER"'" file-hash "'"$LAB_DIR"'/genesis/nano-jit.x86_64" 2>/dev/null | tail -1)
  h1=$("'"$RUNNER"'" file-hash "'"$LAB_DIR"'/genesis/nano-jit.aarch64" 2>/dev/null | tail -1)
  grep -q "x86_64.fnv1a64=$h0" "'"$LAB_DIR"'/genesis/manifest.txt"
  grep -q "aarch64.fnv1a64=$h1" "'"$LAB_DIR"'/genesis/manifest.txt"
'

# --- bootstrap-v3 VM self-pack matrix (plan only; full run needs nano-jit.x86_64 slice) ---
log "bootstrap.v3.vm.matrix.source.path=$BOOTSTRAP_V3_VM_MATRIX_SRC"
run_case "run-bootstrap-v3-vm-matrix-plan" bash -c '
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V3_VM_MATRIX_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=compile"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=compile-expect-exit"
'

# --- v3.5 slice 0: nano-cc CLI + bootstrap DSL ---
log "v35.nano-cc.hello.source.path=$NANO_CC_HELLO_SRC"
run_case "nano-cc-compile-hello-cli" bash -c '
  cd "'"$ROOT_DIR"'" && "'"$RUNNER"'" nano-cc compile "'"$NANO_CC_HELLO_SRC"'" -o "'"$NANO_CC_HELLO_CLI_ELF"'"
  test -x "'"$NANO_CC_HELLO_CLI_ELF"'"
'
run_case "nano-cc-run-hello-exit42" \
  "$RUNNER" run-expect-exit "$NANO_CC_HELLO_CLI_ELF" 42
run_case "nano-cc-compile-bad-expect2" \
  "$RUNNER" nano-cc-compile-expect-exit 2 "$NANO_CC_BAD_SRC" "$BUILD_DIR/nano-cc-bad.elf"
log "bootstrap.v35.nano-cc.hello.source.path=$BOOTSTRAP_V35_NANO_CC_HELLO_SRC"
run_case "run-bootstrap-v35-nano-cc-hello-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_NANO_CC_HELLO_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=nano-cc-compile"
  printf "%s\n" "$out" | grep -q "nano-cc.exit_code=42"
  test -x "'"$NANO_CC_HELLO_ELF"'"
'

# --- v3.5 slice 1: nano-cc parse (add-parse dump) ---
run_case "nano-cc-parse-hello" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" nano-cc parse "'"$NANO_CC_HELLO_SRC"'" 2>&1)
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "nano-cc.parse.kind=main_return"
  printf "%s\n" "$out" | grep -q "nano-cc.parse.exit_code=42"
'
run_case "nano-cc-parse-add" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" nano-cc parse "'"$NANO_CC_ADD_SRC"'" 2>&1)
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "nano-cc.parse.kind=add_module"
  printf "%s\n" "$out" | grep -q "nano-cc.parse.add_a=40"
  printf "%s\n" "$out" | grep -q "nano-cc.parse.add_b=2"
  printf "%s\n" "$out" | grep -q "nano-cc.parse.exit_code=42"
'
run_case "nano-cc-parse-add-golden" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" nano-cc parse "'"$NANO_CC_ADD_SRC"'" 2>&1)
  printf "%s\n" "$out"
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    printf "%s\n" "$out" | grep -qxF "$line"
  done < "'"$NANO_CC_ADD_PARSE_GOLDEN"'"
'
run_case "nano-cc-parse-add-bad-expect2" \
  "$RUNNER" nano-cc-parse-expect-exit 2 "$NANO_CC_ADD_BAD_SIG_SRC"
run_case "nano-cc-parse-add-bad-body-expect2" \
  "$RUNNER" nano-cc-parse-expect-exit 2 "$NANO_CC_ADD_BAD_BODY_SRC"

# --- v3.5 slice 2 emit: nano-cc compile-obj → relocatable .o ---
run_case "nano-cc-compile-obj-hello" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" nano-cc compile-obj "'"$NANO_CC_HELLO_SRC"'" -o "'"$NANO_CC_HELLO_OBJ"'" 2>&1)
  printf "%s\n" "$out"
  test -f "'"$NANO_CC_HELLO_OBJ"'"
  printf "%s\n" "$out" | grep -q "nano-cc.obj.mode=relocatable"
  printf "%s\n" "$out" | grep -q "nano-cc.obj.symbol=main"
  printf "%s\n" "$out" | grep -q "nano-cc.exit_code=42"
'
run_case "nano-cc-link-hello-obj-exit42" bash -c '
  cd "'"$ROOT_DIR"'" && "'"$RUNNER"'" link-elf64-exe "'"$NANO_CC_HELLO_OBJ_EXE"'" main "'"$NANO_CC_HELLO_OBJ"'"
  "'"$RUNNER"'" run-expect-exit "'"$NANO_CC_HELLO_OBJ_EXE"'" 42
'

# --- v3.5 slice 2: nano-cc add — canonical nano-jit-slice-add.lisp (no companion .lisp) ---
log "v35.nano-cc.add.source.path=$NANO_CC_ADD_SRC"
run_case "nano-cc-compile-add-cli" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" nano-cc compile "'"$NANO_CC_ADD_SRC"'" -o "'"$NANO_CC_ADD_CLI_ELF"'" 2>&1)
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "nano-cc.lisp.canonical=lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
  ! printf "%s\n" "$out" | grep -qE "^nano-cc\\.lisp="
  test -x "'"$NANO_CC_ADD_CLI_ELF"'"
  "'"$RUNNER"'" run-expect-exit "'"$NANO_CC_ADD_CLI_ELF"'" 42
'
log "bootstrap.v35.nano-cc.add.source.path=$BOOTSTRAP_V35_NANO_CC_ADD_SRC"
run_case "run-bootstrap-v35-nano-cc-add-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_NANO_CC_ADD_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=nano-cc-compile"
  printf "%s\n" "$out" | grep -q "nano-cc.exit_code=42"
  printf "%s\n" "$out" | grep -q "nano-cc.lisp.canonical=lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
  ! printf "%s\n" "$out" | grep -qE "^nano-cc\\.lisp="
  test -x "'"$NANO_CC_ADD_ELF"'"
'

# --- v3.5 Lisp-only line L0: slice matrix + build-slice .lisp auto-route ---
log "bootstrap.v35.lisp.only.matrix.path=$BOOTSTRAP_V35_LISP_ONLY_MATRIX_SRC"
run_case "run-bootstrap-v35-lisp-only-matrix-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_LISP_ONLY_MATRIX_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice-lisp"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-jit-lisp"
  printf "%s\n" "$out" | grep -q "build-slice.role=lisp-codegen"
  test -x "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-lisp-only-min.elf"
  test -x "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-lisp-only-add.elf"
  printf "%s\n" "$out" | grep -q "build-slice-lisp.mode=compile-elf64"
  ! printf "%s\n" "$out" | grep -qE "build-slice\.source=.*\.c|samples/nano-cc-[^.]+\.c"
'
log "bootstrap.v35.build.slice.lisp.route.path=$BOOTSTRAP_V35_BUILD_SLICE_LISP_ROUTE_SRC"
run_case "run-bootstrap-v35-build-slice-lisp-route-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_BUILD_SLICE_LISP_ROUTE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice"
  printf "%s\n" "$out" | grep -q "build-slice.route=lisp-by-extension"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-jit-lisp"
  test -x "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-lisp-route.elf"
  "'"$RUNNER"'" run-expect-exit "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-lisp-route.elf" 42
'

# --- v3.5 L4 kickoff: multi .lisp TU → compile-elf64-obj-code → link-elf64-exe ---
log "bootstrap.v35.lisp.tu.link.path=$BOOTSTRAP_V35_LISP_TU_LINK_SRC"
run_case "run-bootstrap-v35-lisp-tu-link-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_LISP_TU_LINK_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=compile-elf64-obj-code"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=link-elf64-exe"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file-hash"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=run-expect-exit"
  test -f "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-callee.o"
  test -f "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-main.o"
  test -x "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-linked"
  "'"$RUNNER"'" run-expect-exit "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-lisp-tu-linked" 42
'

# --- v3.5 L3: build-slice-lisp aarch64 exit emit (nano-jit-slice-min.lisp) ---
log "bootstrap.v35.build.slice.lisp.aarch64.source.path=$BOOTSTRAP_V35_BUILD_SLICE_LISP_AARCH64_SRC"
run_case "run-bootstrap-v35-build-slice-lisp-aarch64-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_BUILD_SLICE_LISP_AARCH64_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice-lisp"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-jit-lisp"
  printf "%s\n" "$out" | grep -q "build-slice-lisp.mode=aarch64-exit-emit"
  test -x "'"$BUILD_SLICE_LISP_AARCH64_ELF"'"
  file -b "'"$BUILD_SLICE_LISP_AARCH64_ELF"'" | grep -q "ARM aarch64"
'
if has_qemu_aarch64 && [ -x "$BUILD_SLICE_LISP_AARCH64_ELF" ]; then
  run_case "nano-cc-qemu-aarch64-build-slice-lisp-exit42" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$BUILD_SLICE_LISP_AARCH64_ELF"'"; echo $?)
    printf "qemu-aarch64.build-slice-lisp.exit=%s\n" "$rc"
    test "$rc" -eq 42
  '
else
  skip_case "nano-cc-qemu-aarch64-build-slice-lisp-exit42" "no qemu-aarch64-static or qemu-aarch64"
fi

log "bootstrap.v35.build.slice.lisp.aarch64.add.path=$BOOTSTRAP_V35_BUILD_SLICE_LISP_AARCH64_ADD_SRC"
run_case "run-bootstrap-v35-build-slice-lisp-aarch64-add-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_BUILD_SLICE_LISP_AARCH64_ADD_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "build-slice-lisp.mode=aarch64-add-emit"
  printf "%s\n" "$out" | grep -q "build-slice-lisp.aarch64.profile=nano-jit-slice-add.lisp"
  printf "%s\n" "$out" | grep -q "build-slice-lisp.aarch64.add=40+2"
  test -f "'"$BUILD_SLICE_LISP_AARCH64_ADD_ELF"'"
  file -b "'"$BUILD_SLICE_LISP_AARCH64_ADD_ELF"'" | grep -q "ARM aarch64"
  echo "v35.aarch64_add_emit=1" >> "'"$V35_SIGNOFF_EVIDENCE"'"
'
if has_qemu_aarch64 && [ -f "$BUILD_SLICE_LISP_AARCH64_ADD_ELF" ]; then
  run_case "qemu-aarch64-build-slice-lisp-add-exit42" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$BUILD_SLICE_LISP_AARCH64_ADD_ELF"'"; echo $?)
    printf "qemu-aarch64.add-slice.exit=%s\n" "$rc"
    test "$rc" -eq 42
  '
else
  skip_case "qemu-aarch64-build-slice-lisp-add-exit42" "no qemu or elf missing"
fi

# --- v3.5 L1: pack-ape x86 from Lisp-built slice (aarch64 genesis) ---
log "bootstrap.v35.pack.lisp.x86.path=$BOOTSTRAP_V35_PACK_LISP_X86_SRC"
run_case "run-bootstrap-v35-pack-lisp-x86-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_PACK_LISP_X86_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "build-slice-lisp"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=pack-ape"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=inspect-ape"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=run"
  ! printf "%s\n" "$out" | grep -q "genesis/nano-jit.x86_64"
  test -x "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86-slice.elf"
  test -f "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86.com"
  test -f "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86-arithmetic.lbin"
  slice_h=$("'"$RUNNER"'" file-hash "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86-slice.elf" 2>/dev/null | tail -1)
  genesis_h=$("'"$RUNNER"'" file-hash "'"$LAB_DIR"'/genesis/nano-jit.x86_64" 2>/dev/null | tail -1)
  printf "pack-lisp.x86.slice.hash=%s\n" "$slice_h"
  printf "genesis.x86.hash=%s\n" "$genesis_h"
  [ -n "$slice_h" ] && [ -n "$genesis_h" ] && [ "$slice_h" != "$genesis_h" ]
  inspect=$("'"$RUNNER"'" inspect-ape "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86.com" 2>&1) || true
  printf "%s\n" "$inspect"
  printf "%s\n" "$inspect" | grep -q "inspect-ape.container=ape-v2"
  printf "%s\n" "$inspect" | grep -q "inspect-ape.slice.0.hash=$slice_h"
'

# --- v3.5 slice 3: build-slice via nano-cc (NANO_BUILD_SLICE_CODEGEN=1) ---
log "bootstrap.v35.build.slice.source.path=$BOOTSTRAP_V35_BUILD_SLICE_SRC"
log "v35.nano-cc.build-slice.source.path=$NANO_CC_BUILD_SLICE_SRC"
run_case "run-bootstrap-v35-build-slice-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$(NANO_BUILD_SLICE_CODEGEN=1 "'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_BUILD_SLICE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-cc"
  printf "%s\n" "$out" | grep -q "build-slice.role=lisp-codegen"
  test -x "'"$NANO_CC_BUILD_SLICE_ELF"'"
  "'"$RUNNER"'" run-expect-exit "'"$NANO_CC_BUILD_SLICE_ELF"'" 43
'

# --- v3.5 slice 3: build-slice via nano-cc (NANO_V35_CODEGEN_DEFAULT=1, no per-test NANO_BUILD_SLICE_CODEGEN) ---
run_case "run-bootstrap-v35-build-slice-default-codegen" bash -c '
  cd "'"$ROOT_DIR"'" && out=$(NANO_V35_CODEGEN_DEFAULT=1 "'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_BUILD_SLICE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-cc"
  printf "%s\n" "$out" | grep -q "build-slice.role=lisp-codegen"
  test -x "'"$NANO_CC_BUILD_SLICE_ELF"'"
  "'"$RUNNER"'" run-expect-exit "'"$NANO_CC_BUILD_SLICE_ELF"'" 43
'

# --- v3.5 slice 4: build-slice aarch64 via nano-cc (NANO_BUILD_SLICE_CODEGEN=1) ---
log "bootstrap.v35.build.slice.aarch64.source.path=$BOOTSTRAP_V35_BUILD_SLICE_AARCH64_SRC"
run_case "run-bootstrap-v35-build-slice-aarch64-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$(NANO_BUILD_SLICE_CODEGEN=1 "'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_BUILD_SLICE_AARCH64_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-cc"
  printf "%s\n" "$out" | grep -q "build-slice.role=lisp-codegen"
  test -x "'"$NANO_CC_BUILD_SLICE_AARCH64_ELF"'"
  file -b "'"$NANO_CC_BUILD_SLICE_AARCH64_ELF"'" | grep -q "ARM aarch64"
'
if has_qemu_aarch64 && [ -x "$NANO_CC_BUILD_SLICE_AARCH64_ELF" ]; then
  run_case "nano-cc-qemu-aarch64-build-slice-exit43" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$NANO_CC_BUILD_SLICE_AARCH64_ELF"'"; echo $?)
    printf "qemu-aarch64.build-slice.exit=%s\n" "$rc"
    test "$rc" -eq 43
  '
else
  skip_case "nano-cc-qemu-aarch64-build-slice-exit43" "no qemu-aarch64-static or qemu-aarch64"
fi

# --- v3.5 slice 4: aarch64 nano-cc exit42 (route B) ---
log "v35.nano-cc.aarch64.source.path=$NANO_CC_HELLO_SRC"
run_case "nano-cc-compile-hello-aarch64" bash -c '
  cd "'"$ROOT_DIR"'" && NANO_CC_ARCH=aarch64 "'"$RUNNER"'" nano-cc compile "'"$NANO_CC_HELLO_SRC"'" \
    -o "'"$NANO_CC_HELLO_AARCH64_ELF"'"
  test -x "'"$NANO_CC_HELLO_AARCH64_ELF"'"
  file -b "'"$NANO_CC_HELLO_AARCH64_ELF"'" | grep -q "ARM aarch64"
'
if has_qemu_aarch64; then
  run_case "nano-cc-qemu-aarch64-hello-exit42" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$NANO_CC_HELLO_AARCH64_ELF"'"; echo $?)
    printf "qemu-aarch64.exit=%s\n" "$rc"
    test "$rc" -eq 42
  '
else
  skip_case "nano-cc-qemu-aarch64-hello-exit42" "no qemu-aarch64-static or qemu-aarch64"
fi
log "bootstrap.v35.nano-cc.aarch64.source.path=$BOOTSTRAP_V35_NANO_CC_AARCH64_SRC"
run_case "run-bootstrap-v35-nano-cc-aarch64-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$(env NANO_CC_ARCH=aarch64 "'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_NANO_CC_AARCH64_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=nano-cc-compile"
  printf "%s\n" "$out" | grep -q "nano-cc.arch=aarch64"
  test -x "'"$NANO_CC_HELLO_AARCH64_BOOT_ELF"'"
  file -b "'"$NANO_CC_HELLO_AARCH64_BOOT_ELF"'" | grep -q "ARM aarch64"
'
if has_qemu_aarch64 && [ -x "$NANO_CC_HELLO_AARCH64_BOOT_ELF" ]; then
  run_case "nano-cc-qemu-aarch64-bootstrap-exit42" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$NANO_CC_HELLO_AARCH64_BOOT_ELF"'"; echo $?)
    printf "qemu-aarch64.bootstrap.exit=%s\n" "$rc"
    test "$rc" -eq 42
  '
else
  skip_case "nano-cc-qemu-aarch64-bootstrap-exit42" "no qemu-aarch64 or bootstrap elf missing"
fi

# --- v3.5 slice 6: genesis shrink — lispjit.c daily build-slice uses genesis-pin ---
log "bootstrap.v35.genesis.shrink.source.path=$BOOTSTRAP_V35_GENESIS_SHRINK_SRC"
run_case "run-bootstrap-v35-genesis-shrink-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_GENESIS_SHRINK_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice"
  printf "%s\n" "$out" | grep -q "build-slice.role=genesis-pin"
  ! printf "%s\n" "$out" | grep -q "build-slice.compiler=cc"
  test -f "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-genesis-shrink-x86.elf"
  test -f "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-genesis-shrink-aarch64.elf"
  file -b "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v35-genesis-shrink-aarch64.elf" | grep -q "ARM aarch64"
'
run_case "genesis-shrink-no-host-cc-build-log" audit_genesis_shrink_log "$RESULTS"

# --- bootstrap-v3 slice 4b codegen (lisp + nano-cc, no host cc for smoke artifacts) ---
log "bootstrap.v3.build.slice.lisp.source.path=$BOOTSTRAP_V3_BUILD_SLICE_LISP_SRC"
run_case "run-bootstrap-v3-build-slice-lisp-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V3_BUILD_SLICE_LISP_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice-lisp"
  printf "%s\n" "$out" | grep -q "build-slice.role=lisp-codegen"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-jit-lisp"
  test -x "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v3-slice-lisp-x86.elf"
'
run_case "run-bootstrap-v3-codegen-smoke-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V3_CODEGEN_SMOKE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-jit-lisp"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-cc"
  test -x "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v3-codegen-lisp.elf"
  test -x "'"$ROOT_DIR"'/lab/nano-lisp-jit/.build/bootstrap-v3-codegen-nano-cc.elf"
'

# --- bootstrap-v3 selfhost thorough (B-layer genesis→gen1→gen2 orchestration) ---
log "bootstrap.v3.selfhost.gen1.source.path=$BOOTSTRAP_V3_SELFHOST_GEN1_SRC"
if [ -f "$SELFHOST_DIR/gen1-nano-jit.com" ]; then
run_case "run-bootstrap-v3-selfhost-gen1-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V3_SELFHOST_GEN1_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=pack-ape"
  printf "%s\n" "$out" | grep -q "build-slice.role=stage0-bridge"
  test -x "'"$SELFHOST_DIR"'/gen1-slice-x86.elf"
  test -f "'"$SELFHOST_DIR"'/gen1-nano-jit.com"
'
else
  skip_case "run-bootstrap-v3-selfhost-gen1-plan" "gen1 artifacts missing (dev container selfhost)"
fi
if [ -x "$SELFHOST_DIR/gen1-slice-x86.elf" ]; then
  log "bootstrap.v3.selfhost.gen2.source.path=$BOOTSTRAP_V3_SELFHOST_GEN2_SRC"
  run_case "run-bootstrap-v3-selfhost-gen2-plan" bash -c '
    cd "'"$ROOT_DIR"'" && out=$("'"$SELFHOST_DIR"'/gen1-slice-x86.elf" run-bootstrap-plan "'"$BOOTSTRAP_V3_SELFHOST_GEN2_SRC"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "bootstrap-step.*=build-slice"
    printf "%s\n" "$out" | grep -q "bootstrap-step.*=run"
    test -x "'"$SELFHOST_DIR"'/gen2-slice-x86.elf"
    test -f "'"$SELFHOST_DIR"'/gen2-arithmetic.lbin"
  '
  run_case "run-bootstrap-v3-selfhost-gen2-arithmetic" \
    "$SELFHOST_DIR/gen2-slice-x86.elf" run "$SELFHOST_DIR/gen2-arithmetic.lbin"
else
  skip_case "run-bootstrap-v3-selfhost-gen2-plan" "gen1-slice-x86.elf missing after gen1 plan"
  skip_case "run-bootstrap-v3-selfhost-gen2-arithmetic" "gen1-slice-x86.elf missing after gen1 plan"
fi
if [ -x "$SELFHOST_DIR/gen2-slice-x86.elf" ]; then
  log "bootstrap.v3.selfhost.gen3.source.path=$BOOTSTRAP_V3_SELFHOST_GEN3_SRC"
  run_case "run-bootstrap-v3-selfhost-gen3-plan" bash -c '
    cd "'"$ROOT_DIR"'" && out=$("'"$SELFHOST_DIR"'/gen2-slice-x86.elf" run-bootstrap-plan "'"$BOOTSTRAP_V3_SELFHOST_GEN3_SRC"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "build-slice-lisp"
    printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-cc"
    test -x "'"$SELFHOST_DIR"'/gen3-slice-lisp-x86.elf"
    test -x "'"$SELFHOST_DIR"'/gen3-slice-x86.elf"
  '
else
  skip_case "run-bootstrap-v3-selfhost-gen3-plan" "gen2-slice-x86.elf missing"
fi
if [ -x "$SELFHOST_DIR/gen2-slice-x86.elf" ]; then
  log "bootstrap.v35.selfhost.gen3.source.path=$BOOTSTRAP_V35_SELFHOST_GEN3_SRC"
  run_case "run-bootstrap-v35-selfhost-gen3-plan" bash -c '
    cd "'"$ROOT_DIR"'" && out=$("'"$SELFHOST_DIR"'/gen2-slice-x86.elf" run-bootstrap-plan "'"$BOOTSTRAP_V35_SELFHOST_GEN3_SRC"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "build-slice-lisp"
    printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-cc"
    printf "%s\n" "$out" | grep -q "bootstrap-step.*=pack-ape"
    printf "%s\n" "$out" | grep -q "bootstrap-step.*=run"
    ! printf "%s\n" "$out" | grep -q "build-slice.role=genesis-pin"
    test -x "'"$SELFHOST_DIR"'/v35-gen3-slice-lisp-x86.elf"
    test -x "'"$SELFHOST_DIR"'/v35-gen3-slice-nano-cc-x86.elf"
    test -f "'"$SELFHOST_DIR"'/v35-gen3-nano-jit.com"
  '
else
  skip_case "run-bootstrap-v35-selfhost-gen3-plan" "gen2-slice-x86.elf missing"
fi
log "bootstrap.v35.selfhost.gen4.source.path=$BOOTSTRAP_V35_SELFHOST_GEN4_SRC"
if [ -f "$SELFHOST_DIR/v35-gen4-nano-jit.com" ]; then
run_case "run-bootstrap-v35-selfhost-gen4-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_SELFHOST_GEN4_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "build-slice-lisp"
  printf "%s\n" "$out" | grep -q "build-slice.compiler=nano-jit-lisp"
  printf "%s\n" "$out" | grep -q "build-slice-lisp.mode=compile-elf64-exe"
  ! printf "%s\n" "$out" | grep -qE "build-slice\.source=.*nano-cc-[^.]+\.c"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=pack-ape"
  ! printf "%s\n" "$out" | grep -q "genesis/nano-jit.x86_64"
  test -x "'"$SELFHOST_DIR"'/v35-gen4-slice-min-x86.elf"
  test -x "'"$SELFHOST_DIR"'/v35-gen4-slice-add-x86.elf"
  test -f "'"$SELFHOST_DIR"'/v35-gen4-nano-jit.com"
  test -f "'"$SELFHOST_DIR"'/v35-gen4-arithmetic.lbin"
  slice_h=$("'"$RUNNER"'" file-hash "'"$SELFHOST_DIR"'/v35-gen4-slice-min-x86.elf" 2>/dev/null | tail -1)
  inspect=$("'"$RUNNER"'" inspect-ape "'"$SELFHOST_DIR"'/v35-gen4-nano-jit.com" 2>&1) || true
  printf "%s\n" "$inspect"
  printf "%s\n" "$inspect" | grep -q "inspect-ape.slice.0.hash=$slice_h"
'
else
  skip_case "run-bootstrap-v35-selfhost-gen4-plan" "v35-gen4 artifacts missing"
fi

# --- v3.5 wave-4: signoff evidence via bootstrap plan ---
log "bootstrap.v35.signoff.evidence.path=$BOOTSTRAP_V35_SIGNOFF_EVIDENCE_SRC"
run_case "run-bootstrap-v35-signoff-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_SIGNOFF_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "build-slice-lisp.mode=aarch64-add-emit"
  test -f "'"$BUILD_DIR"'/bootstrap-v35-signoff-aarch64-add.elf"
  echo "v35.signoff_bootstrap_plan=1" >> "'"$V35_SIGNOFF_EVIDENCE"'"
  echo "v35.signoff_bootstrap_plan=1" >> "'"$V35_TERMINAL_EVIDENCE"'"
'

# --- v3.5 terminal: genesis pin must match native runner (parser drift guard) ---
run_case "v35-genesis-pin-matches-native-runner" bash -c '
  runner_h=$("'"$RUNNER"'" file-hash "'"$RUNNER"'" 2>/dev/null | tail -1)
  genesis_h=$("'"$RUNNER"'" file-hash "'"$LAB_DIR"'/genesis/nano-jit.x86_64" 2>/dev/null | tail -1)
  printf "runner.hash=%s\n" "$runner_h"
  printf "genesis.x86.hash=%s\n" "$genesis_h"
  test -n "$runner_h" && test -n "$genesis_h" && test "$runner_h" = "$genesis_h"
  echo "v35.genesis_pin_ok=1" >> "'"$V35_TERMINAL_EVIDENCE"'"
'

# --- v3.5 gen5: dual-arch Lisp pack, zero genesis pin, zero .c ---
log "bootstrap.v35.selfhost.gen5.source.path=$BOOTSTRAP_V35_SELFHOST_GEN5_SRC"
if [ -f "$SELFHOST_DIR/v35-gen5-nano-jit.com" ]; then
run_case "run-bootstrap-v35-selfhost-gen5-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V35_SELFHOST_GEN5_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "build-slice-lisp"
  printf "%s\n" "$out" | grep -q "build-slice-lisp.mode=aarch64-exit-emit"
  printf "%s\n" "$out" | grep -q "build-slice-lisp.mode=aarch64-add-emit"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=pack-ape"
  ! printf "%s\n" "$out" | grep -q "genesis/nano-jit"
  ! printf "%s\n" "$out" | grep -qE "build-slice\.source=.*\.c"
  test -x "'"$SELFHOST_DIR"'/v35-gen5-slice-min-x86.elf"
  test -x "'"$SELFHOST_DIR"'/v35-gen5-slice-add-x86.elf"
  test -f "'"$SELFHOST_DIR"'/v35-gen5-slice-min-aarch64.elf"
  test -f "'"$SELFHOST_DIR"'/v35-gen5-slice-add-aarch64.elf"
  test -f "'"$SELFHOST_DIR"'/v35-gen5-nano-jit.com"
  test -f "'"$SELFHOST_DIR"'/v35-gen5-arithmetic.lbin"
  slice_x=$("'"$RUNNER"'" file-hash "'"$SELFHOST_DIR"'/v35-gen5-slice-min-x86.elf" 2>/dev/null | tail -1)
  slice_a=$("'"$RUNNER"'" file-hash "'"$SELFHOST_DIR"'/v35-gen5-slice-min-aarch64.elf" 2>/dev/null | tail -1)
  test -n "$slice_x" && test -n "$slice_a" && test "$slice_x" != "$slice_a"
  inspect=$("'"$RUNNER"'" inspect-ape "'"$SELFHOST_DIR"'/v35-gen5-nano-jit.com" 2>&1) || true
  printf "%s\n" "$inspect"
  printf "%s\n" "$inspect" | grep -q "inspect-ape.slice.0.hash=$slice_x"
  printf "%s\n" "$inspect" | grep -q "inspect-ape.slice.1.hash=$slice_a"
'
else
  skip_case "run-bootstrap-v35-selfhost-gen5-plan" "v35-gen5 artifacts missing"
fi
GEN5_SLICE_MIN_AARCH64="$SELFHOST_DIR/v35-gen5-slice-min-aarch64.elf"
if has_qemu_aarch64 && [ -f "$GEN5_SLICE_MIN_AARCH64" ]; then
  run_case "qemu-aarch64-v35-gen5-slice-min-exit42" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$GEN5_SLICE_MIN_AARCH64"'"; echo $?)
    printf "qemu-aarch64.gen5-slice-min.exit=%s\n" "$rc"
    test "$rc" -eq 42
  '
else
  skip_case "qemu-aarch64-v35-gen5-slice-min-exit42" "no qemu-aarch64 or slice missing"
fi

if [ -x "$SELFHOST_DIR/gen2-slice-x86.elf" ]; then
  run_case "run-bootstrap-v35-selfhost-gen5-gen2-runner-plan" bash -c '
    cd "'"$ROOT_DIR"'" && out=$("'"$SELFHOST_DIR"'/gen2-slice-x86.elf" run-bootstrap-plan "'"$BOOTSTRAP_V35_SELFHOST_GEN5_GEN2_SRC"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "build-slice-lisp"
    printf "%s\n" "$out" | grep -q "bootstrap-step.*=pack-ape"
    test -f "'"$SELFHOST_DIR"'/v35-gen5g2-nano-jit.com"
    test -f "'"$SELFHOST_DIR"'/v35-gen5g2-arithmetic.lbin"
  '
else
  skip_case "run-bootstrap-v35-selfhost-gen5-gen2-runner-plan" "gen2-slice-x86.elf missing (run selfhost gen1/2 first)"
fi

if [ -x "$SELFHOST_DIR/gen2-slice-x86.elf" ]; then
  log "bootstrap.v35.selfhost.gen5.via.gen2.path=$BOOTSTRAP_V35_SELFHOST_GEN5_VIA_GEN2_SRC"
  run_case "run-bootstrap-v35-selfhost-gen5-via-gen2-plan" bash -c '
    cd "'"$ROOT_DIR"'" && out=$("'"$SELFHOST_DIR"'/gen2-slice-x86.elf" run-bootstrap-plan "'"$BOOTSTRAP_V35_SELFHOST_GEN5_VIA_GEN2_SRC"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "build-slice-lisp"
    printf "%s\n" "$out" | grep -q "build-slice-lisp.mode=aarch64-add-emit"
    printf "%s\n" "$out" | grep -q "bootstrap-step.*=pack-ape"
    printf "%s\n" "$out" | grep -q "bootstrap-step.*=run"
    ! printf "%s\n" "$out" | grep -q "genesis/nano-jit"
    test -f "'"$SELFHOST_DIR"'/v35-gen5v2-nano-jit.com"
    test -f "'"$SELFHOST_DIR"'/v35-gen5v2-arithmetic.lbin"
    echo "v35.gen5_lisp_runner=1" >> "'"$V35_SIGNOFF_EVIDENCE"'"
  '
else
  skip_case "run-bootstrap-v35-selfhost-gen5-via-gen2-plan" "gen2-slice-x86.elf missing"
fi

if [ -x "$SELFHOST_DIR/gen2-slice-x86.elf" ]; then
  log "bootstrap.v35.selfhost.gen5.gen2-full.path=$BOOTSTRAP_V35_SELFHOST_GEN5_SRC"
  run_case "run-bootstrap-v35-selfhost-gen5-gen2-full-plan" bash -c '
    cd "'"$ROOT_DIR"'" && out=$("'"$SELFHOST_DIR"'/gen2-slice-x86.elf" run-bootstrap-plan "'"$BOOTSTRAP_V35_SELFHOST_GEN5_SRC"'" 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "bootstrap-step.*=pack-ape"
    printf "%s\n" "$out" | grep -q "bootstrap-step.*=run"
    test -f "'"$SELFHOST_DIR"'/v35-gen5-nano-jit.com"
    test -f "'"$SELFHOST_DIR"'/v35-gen5-arithmetic.lbin"
    echo "v35.gen2_gen5_full=1" >> "'"$V35_TERMINAL_EVIDENCE"'"
  '
else
  skip_case "run-bootstrap-v35-selfhost-gen5-gen2-full-plan" "gen2-slice-x86.elf missing"
fi

# --- v4 kickoff ---
log "bootstrap.v4.kickoff.path=$BOOTSTRAP_V4_KICKOFF_SRC"
run_case "run-bootstrap-v4-kickoff-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_KICKOFF_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=run"
  test -f "'"$BUILD_DIR"'/bootstrap-v4-kickoff-arithmetic.lbin"
'
run_case "run-bootstrap-v4-aarch64-aot-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_AARCH64_AOT_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "build-slice-lisp"
  test -f "'"$BUILD_DIR"'/bootstrap-v4-aarch64-add-scout.elf"
'
run_case "run-bootstrap-v4-squad-dispatch-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_DISPATCH_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
'
run_case "run-bootstrap-v4-squad-run-loop-once-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_RUN_LOOP_ONCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
'
run_case "run-bootstrap-v4-slice0-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE0_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "build-slice-lisp"
  test -f "'"$BUILD_DIR"'/bootstrap-v4-aarch64-add-scout.elf"
  {
    echo "v4.slice0=1"
    echo "v4.aarch64_scout=1"
    echo "v4.squad_s0_s3=1"
    echo "v4.slice0_plan=run-bootstrap-v4-slice0-evidence-plan"
  } >> "'"$V4_SLICE0_EVIDENCE"'"
'
run_case "run-bootstrap-v4-slice1-add7-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE1_ADD7_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "aarch64.add=3+4"
  test -f "'"$V4_SLICE1_ADD7_ELF"'"
'
run_case "run-bootstrap-v4-squad-signal-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_SIGNAL_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
'
run_case "run-bootstrap-v4-slice1-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE1_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "aarch64.add=3+4"
  test -f "'"$V4_SLICE1_ADD7_ELF"'"
  {
    echo "v4.slice1=1"
    echo "v4.slice1_add7=1"
    echo "v4.slice1_plan=run-bootstrap-v4-slice1-evidence-plan"
  } >> "'"$V4_SLICE1_EVIDENCE"'"
'
if has_qemu_aarch64 && [ -f "$V4_AARCH64_SCOUT_ELF" ]; then
  run_case "qemu-aarch64-v4-scout-add-exit42" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$V4_AARCH64_SCOUT_ELF"'"; echo $?)
    printf "qemu-aarch64.v4-scout.exit=%s\n" "$rc"
    test "$rc" -eq 42
  '
else
  skip_case "qemu-aarch64-v4-scout-add-exit42" "no qemu or v4 scout elf"
fi
if has_qemu_aarch64 && [ -f "$V4_SLICE1_ADD7_ELF" ]; then
  run_case "qemu-aarch64-v4-slice1-add7-exit7" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$V4_SLICE1_ADD7_ELF"'"; echo $?)
    printf "qemu-aarch64.v4-slice1-add7.exit=%s\n" "$rc"
    test "$rc" -eq 7
  '
else
  skip_case "qemu-aarch64-v4-slice1-add7-exit7" "no qemu or slice1 add7 elf"
fi
run_case "v4-bootstrap-plans-no-c" bash -c '
  bad=0
  for f in "'"$LAB_DIR"'"/samples/bootstrap-v4-*.lisp; do
    [ -f "$f" ] || continue
    if awk "!/^[[:space:]]*;/ && /\.c/ && !/\(file-(hash|size)/" "$f" | grep -q .; then
      echo "v4.plan.bad=$f"
      bad=1
    fi
  done
  test "$bad" -eq 0
  echo "v4.plans_no_c=1" >> "'"$V4_LISP_ONLY_EVIDENCE"'"
'
run_case "run-bootstrap-v4-gen5-anchor-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_GEN5_ANCHOR_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
  ! awk "!/^[[:space:]]*;/ && /\.c/" "'"$BOOTSTRAP_V35_SELFHOST_GEN5_SRC"'" | grep -q .
  echo "v4.gen5_anchor=1" >> "'"$V4_LISP_ONLY_EVIDENCE"'"
'
run_case "run-bootstrap-v4-squad-s2-state-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S2_STATE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
  test -f "'"$LAB_DIR"'/.squad/state-v4.db"
'
run_case "run-bootstrap-v4-gen5-via-gen2-anchor-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_GEN5_VIA_GEN2_ANCHOR_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  test -f "'"$SELFHOST_DIR"'/v35-gen5v2-slice-min-x86.elf" || {
    echo "skip: gen5v2 artifacts missing (run gen5-via-gen2 first)"
    exit 0
  }
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
'
run_case "run-bootstrap-v4-slice2-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE2_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  test -f "'"$LAB_DIR"'/.squad/state-v4.db"
  {
    echo "v4.slice2=1"
    echo "v4.slice2_s2_state=1"
    echo "v4.slice2_gen5v2_anchor=1"
    echo "v4.slice2_plan=run-bootstrap-v4-slice2-evidence-plan"
  } >> "'"$V4_SLICE2_EVIDENCE"'"
'
run_case "run-bootstrap-v4-squad-s3-supervise-once-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S3_SUPERVISE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
'
run_case "run-bootstrap-v4-squad-s3-member-once-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S3_MEMBER_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
'
run_case "squad-v4-supervise-once" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" supervise --once 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "supervise-tick:"
'
run_case "squad-v4-run-loop-engineer-once" bash -c '
  ae=" --auto-exec"
  if [[ "${SQUAD_VERIFY:-}" = "1" ]]; then ae=" --no-auto-exec"; fi
  cd "'"$ROOT_DIR"'" && out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" run-loop --role engineer-a --once${ae} 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "run-loop role=engineer-a"
'
run_case "squad-v4-run-loop-reviewer-once" bash -c '
  ae=""
  if [[ "${SQUAD_VERIFY:-}" = "1" ]]; then ae=" --no-auto-exec"; fi
  cd "'"$ROOT_DIR"'" && out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" run-loop --role reviewer --once${ae} 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "run-loop role=reviewer"
'
run_case "squad-v4-resume-resets-wave" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" resume --reason run-sh-smoke 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "wave=1"
'
run_case "run-bootstrap-v4-slice3-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE3_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  test -f "'"$LAB_DIR"'/.squad/state-v4.db"
  {
    echo "v4.slice3=1"
    echo "v4.slice3_supervise_once=1"
    echo "v4.slice3_member_once=1"
    echo "v4.slice3_plan=run-bootstrap-v4-slice3-evidence-plan"
  } >> "'"$V4_SLICE3_EVIDENCE"'"
'
run_case "run-bootstrap-v4-squad-s4-agent-team-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S4_AGENT_TEAM_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
'
run_case "run-bootstrap-v4-slice4-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE4_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  test -f "'"$LAB_DIR"'/.squad/state-v4.db"
  {
    echo "v4.slice4=1"
    echo "v4.slice4_agent_team_plan=1"
    echo "v4.slice4_commander_complete=1"
    echo "v4.slice4_plan=run-bootstrap-v4-slice4-evidence-plan"
  } >> "'"$V4_SLICE4_EVIDENCE"'"
'
run_case "run-bootstrap-v4-squad-s5-verify-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S5_VERIFY_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file"
'
run_case "run-bootstrap-v4-slice5-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE5_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  test -f "'"$LAB_DIR"'/.squad/state-v4.db"
  {
    echo "v4.slice5=1"
    echo "v4.slice5_verify_plan=1"
    echo "v4.slice5_plan=run-bootstrap-v4-slice5-evidence-plan"
  } >> "'"$V4_SLICE5_EVIDENCE"'"
'
run_case "run-bootstrap-v4-codegen-kickoff-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_CODEGEN_KICKOFF_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "bootstrap-step.*=file-hash"
  printf "%s\n" "$out" | grep -q "aarch64.add=3+4"
  printf "%s\n" "$out" | grep -q "aarch64.emit.profile=add-exit-v1"
  printf "%s\n" "$out" | grep -q "aarch64.emit.lowering.ops=5"
'
run_case "run-bootstrap-v4-slice7-add11-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE7_ADD11_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "aarch64.add=5+6"
  printf "%s\n" "$out" | grep -q "aarch64.emit.profile=add-exit-v1"
  test -f "'"$V4_SLICE7_ADD11_ELF"'"
'
run_case "run-bootstrap-v4-slice7-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE7_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  {
    echo "v4.slice7=1"
    echo "v4.slice7_add11=1"
    echo "v4.slice7_emit_profile=1"
    echo "v4.slice7_plan=run-bootstrap-v4-slice7-evidence-plan"
  } >> "'"$V4_SLICE7_EVIDENCE"'"
'
if has_qemu_aarch64 && [ -f "$V4_SLICE7_ADD11_ELF" ]; then
  run_case "qemu-aarch64-v4-slice7-add11-exit11" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$V4_SLICE7_ADD11_ELF"'"; echo $?)
    printf "qemu-aarch64.v4-slice7-add11.exit=%s\n" "$rc"
    test "$rc" -eq 11
  '
else
  skip_case "qemu-aarch64-v4-slice7-add11-exit11" "no qemu or slice7 add11 elf"
fi
run_case "run-bootstrap-v4-slice8-add13-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE8_ADD13_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "aarch64.add=8+5"
  printf "%s\n" "$out" | grep -q "aarch64.emit.lowering=table-v1"
  test -f "'"$V4_SLICE8_ADD13_ELF"'"
'
run_case "run-bootstrap-v4-slice8-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE8_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  {
    echo "v4.slice8=1"
    echo "v4.slice8_lowering_table=1"
    echo "v4.slice8_add13=1"
    echo "v4.slice8_plan=run-bootstrap-v4-slice8-evidence-plan"
  } >> "'"$V4_SLICE8_EVIDENCE"'"
'
if has_qemu_aarch64 && [ -f "$V4_SLICE8_ADD13_ELF" ]; then
  run_case "qemu-aarch64-v4-slice8-add13-exit13" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$V4_SLICE8_ADD13_ELF"'"; echo $?)
    printf "qemu-aarch64.v4-slice8-add13.exit=%s\n" "$rc"
    test "$rc" -eq 13
  '
else
  skip_case "qemu-aarch64-v4-slice8-add13-exit13" "no qemu or slice8 add13 elf"
fi
run_case "run-bootstrap-v4-slice9-add14-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE9_ADD14_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "aarch64.add=6+8"
  printf "%s\n" "$out" | grep -q "aarch64.emit.lowering.ops=5"
  test -f "'"$V4_SLICE9_ADD14_ELF"'"
'
run_case "run-bootstrap-v4-slice9-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE9_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  {
    echo "v4.slice9=1"
    echo "v4.slice9_opcode_table=1"
    echo "v4.slice9_add14=1"
    echo "v4.slice9_plan=run-bootstrap-v4-slice9-evidence-plan"
  } >> "'"$V4_SLICE9_EVIDENCE"'"
'
if has_qemu_aarch64 && [ -f "$V4_SLICE9_ADD14_ELF" ]; then
  run_case "qemu-aarch64-v4-slice9-add14-exit14" bash -c '
    QEMU_AARCH64="$(command -v qemu-aarch64-static || command -v qemu-aarch64)"
    rc=$("$QEMU_AARCH64" "'"$V4_SLICE9_ADD14_ELF"'"; echo $?)
    printf "qemu-aarch64.v4-slice9-add14.exit=%s\n" "$rc"
    test "$rc" -eq 14
  '
else
  skip_case "qemu-aarch64-v4-slice9-add14-exit14" "no qemu or slice9 add14 elf"
fi

run_case "run-bootstrap-v4-slice10-ir-entry-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE10_IR_ENTRY_SRC"'" 2>&1) || true
  printf "%s\n" "$out" | grep -q "aarch64.emit.ir.entry=v1"
  test -f "'"$V4_SLICE10_ADD15_ELF"'"
'
run_case "run-bootstrap-v4-squad-s6-assess-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S6_ASSESS_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/squad/catalog-v4.yaml"
'
run_case "run-bootstrap-v4-slice11-ir-table-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE11_IR_TABLE_SRC"'" 2>&1) || true
  printf "%s\n" "$out" | grep -q "aarch64.emit.ir.table.version=v2"
  test -f "'"$V4_SLICE11_ADD16_ELF"'"
'
run_case "run-bootstrap-v4-squad-s6-dispatch-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S6_DISPATCH_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-dispatch.lisp"
'
run_case "run-bootstrap-v4-slice12-ir-table-v3-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE12_IR_TABLE_V3_SRC"'" 2>&1) || true
  printf "%s\n" "$out" | grep -q "aarch64.emit.ir.table.version=v3"
  test -f "'"$V4_SLICE12_ADD17_ELF"'"
'
run_case "run-bootstrap-v4-squad-s7-signal-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S7_SIGNAL_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/squad/PROTOCOL.md"
'
run_case "run-bootstrap-v4-slice13-emit-manifest-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE13_EMIT_MANIFEST_SRC"'" 2>&1) || true
  printf "%s\n" "$out" | grep -q "aarch64.emit.manifest=add-exit-v1" || test -f "'"$LAB_DIR"'/v4/SLICE13.md"
'
run_case "run-bootstrap-v4-squad-s8-resume-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S8_RESUME_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/COMPLETE-SCOPED.md"
'
run_case "run-bootstrap-v4-slice14-complete-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE14_COMPLETE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/COMPLETE-SCOPED.md"
'
run_case "run-bootstrap-v4-slice15-table-only-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE15_TABLE_ONLY_SRC"'" 2>&1) || true
  printf "%s\n" "$out" | grep -q "aarch64.emit.encode=table-only"
  printf "%s\n" "$out" | grep -q "aarch64.emit.ir.table.version=v4"
  test -f "'"$V4_SLICE15_ADD18_ELF"'"
'
run_case "run-bootstrap-v4-build-graph-smoke-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_BUILD_GRAPH_SMOKE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-kickoff.lisp"
'
run_case "run-bootstrap-v4-squad-s9-done-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_S9_DONE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/POST-V4.md"
'
run_case "run-bootstrap-v4-slice15-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE15_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE15.md"
  { echo "v4.slice15=1"; } >> "'"$V4_SLICE15_EVIDENCE"'"
'
run_case "run-bootstrap-v4-squad-assess-scoped-ready-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_ASSESS_SCOPED_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/COMPLETE-SCOPED.md"
  test -f "'"$LAB_DIR"'/squad/catalog-v4.yaml"
'


run_case "run-bootstrap-v4-slice17-verify-words-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE17_VERIFY_WORDS_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-words-v1"
  test -f "'"$V4_SLICE17_ADD20_ELF"'"
'
run_case "run-bootstrap-v4-squad-assess-once-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_ASSESS_ONCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/PROGRESS.md"
'
run_case "run-bootstrap-v4-slice17-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE17_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE17.md"
  { echo "v4.slice17=1"; } >> "'"$V4_SLICE17_EVIDENCE"'"
'
run_case "run-bootstrap-v4-slice18-ir-table-op-plan" bash -c '''
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE18_IR_TABLE_OP_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.op.svc0.from=plan-lisp-v1"
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.version=v6"
  test -f "'"$V4_SLICE18_ADD21_ELF"'"
'''

run_case "run-bootstrap-v4-slice18-evidence-plan" bash -c '''
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE18_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE18.md"
  test -f "'"$V4_SLICE18_ADD21_ELF"'"
  { echo "v4.slice18=1"; } >> "'"$V4_SLICE18_EVIDENCE"'"
'''

run_case "run-bootstrap-v4-host-reduce-plan" bash -c '''
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_HOST_REDUCE_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "squad-assess.cmd="
  printf "%s
" "$out" | grep -q "results-min.key=build.pass"
  pass=$(grep -E "^build\.pass=" "'"$BOOTSTRAP_REPORT"'" | tail -1 | cut -d= -f2)
  test -n "$pass" && test "$pass" -ge 26
'''


run_case "run-bootstrap-v4-wave27-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE27_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.source=plan-lisp-v1-full"
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.version=v7"
  test -f "'"$V4_SLICE27_ADD22_ELF"'"
'

run_case "run-bootstrap-v4-build-graph-wave27-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_BUILD_GRAPH_WAVE27_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-wave27-diffusion.lisp"
'

run_case "run-bootstrap-v4-squad-orchestration-bundle-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_ORCH_BUNDLE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-dispatch.lisp"
'

run_case "run-bootstrap-v4-slice27-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE27_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/EVAL.md"
  { echo "v4.slice27=1"; } >> "'"$V4_SLICE27_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave28-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE28_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE28_ADD23_ELF"'"
'

run_case "run-bootstrap-v4-build-graph-full-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_BUILD_GRAPH_FULL_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-wave28-diffusion.lisp"
'

run_case "run-bootstrap-v4-plan-contract-bundle-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_PLAN_CONTRACT_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/v4-ir-words-v2.txt"
'

run_case "run-bootstrap-v4-assess-evidence-chain-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_ASSESS_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/EVAL.md"
'

run_case "run-bootstrap-v4-slice28-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE28_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE28.md"
  { echo "v4.slice28=1"; } >> "'"$V4_SLICE28_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave29-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  test -f "'"$LAB_DIR"'/.build/results.txt"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE29_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  printf "%s
" "$out" | grep -q "results-min.key=tests.pass"
  test -f "'"$V4_SLICE29_ADD24_ELF"'"
'

run_case "run-bootstrap-v4-squad-four-roles-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_FOUR_ROLES_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-s4-agent-team.lisp"
'

run_case "run-bootstrap-v4-build-gates-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  test -f "'"$LAB_DIR"'/.build/results.txt"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_BUILD_GATES_PLAN_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "results-min.key=build.pass"
  printf "%s
" "$out" | grep -q "results-min.key=tests.pass"
'

run_case "run-bootstrap-v4-plan-manifest-anchor-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_PLAN_MANIFEST_ANCHOR_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/v4-plan-manifest-v1.lisp"
'

run_case "run-bootstrap-v4-slice29-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE29_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE29.md"
  { echo "v4.slice29=1"; } >> "'"$V4_SLICE29_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave30-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE30_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE30_ADD25_ELF"'"
'

run_case "run-bootstrap-v4-squad-supervise-chain-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_SUPERVISE_CHAIN_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-s9-done.lisp"
'

run_case "run-bootstrap-v4-contract-regression-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_CONTRACT_REGRESSION_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/v4-plan-manifest-v1.lisp"
'

run_case "run-bootstrap-v4-onion-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_ONION_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/v4-onion-rings-v1.lisp"
'

run_case "run-bootstrap-v4-slice30-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE30_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE30.md"
  { echo "v4.slice30=1"; } >> "'"$V4_SLICE30_EVIDENCE"'"
'


run_case "run-bootstrap-v4-wave31-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE31_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE31_ADD26_ELF"'"
'

run_case "run-bootstrap-v4-squad-commander-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_COMMANDER_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/COMPLETE-SCOPED.md"
'

run_case "run-bootstrap-v4-evidence-matrix-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_EVIDENCE_MATRIX_SRC"'" 2>&1) || true
  test -f "'"$V4_SLICE27_EVIDENCE"'"
  test -f "'"$V4_SLICE28_EVIDENCE"'"
  test -f "'"$V4_SLICE29_EVIDENCE"'"
  test -f "'"$V4_TERMINAL_EVIDENCE"'"
  test -f "'"$LAB_DIR"'/samples/v4-wave-index-v1.lisp"
'

run_case "run-bootstrap-v4-post-v4-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_POST_V4_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/POST-V4.md"
  test -f "'"$LAB_DIR"'/samples/v4-onion-rings-v1.lisp"
'

run_case "run-bootstrap-v4-slice31-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE31_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE31.md"
  { echo "v4.slice31=1"; } >> "'"$V4_SLICE31_EVIDENCE"'"
'


run_case "run-bootstrap-v4-wave32-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE32_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE32_ADD27_ELF"'"
'

run_case "run-bootstrap-v4-squad-resume-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_RESUME_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-s8-resume.lisp"
'

run_case "run-bootstrap-v4-lisp-only-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_LISP_ONLY_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/LISP-ONLY.md"
  test -f "'"$V4_LISP_ONLY_EVIDENCE"'"
'

run_case "run-bootstrap-v4-slice32-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE32_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE32.md"
  { echo "v4.slice32=1"; } >> "'"$V4_SLICE32_EVIDENCE"'"
'


run_case "run-bootstrap-v4-wave33-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE33_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE33_ADD28_ELF"'"
'

run_case "run-bootstrap-v4-build-graph-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_BUILD_GRAPH_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-build-graph-full.lisp"
'

run_case "run-bootstrap-v4-assess-chain-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_ASSESS_CHAIN_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-host-reduce.lisp"
'

run_case "run-bootstrap-v4-slice33-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE33_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE33.md"
  { echo "v4.slice33=1"; } >> "'"$V4_SLICE33_EVIDENCE"'"
'


run_case "run-bootstrap-v4-wave34-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE34_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE34_ADD29_ELF"'"
'

run_case "run-bootstrap-v4-plan-contract-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_PLAN_CONTRACT_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/v4-plan-manifest-v1.lisp"
'

run_case "run-bootstrap-v4-terminal-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_TERMINAL_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/DECISION.md"
  test -f "'"$V4_TERMINAL_EVIDENCE"'"
'

run_case "run-bootstrap-v4-slice34-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE34_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE34.md"
  { echo "v4.slice34=1"; } >> "'"$V4_SLICE34_EVIDENCE"'"
'


run_case "run-bootstrap-v4-wave35-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE35_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE35_ADD30_ELF"'"
'

run_case "run-bootstrap-v4-wave35-contract-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE35_CONTRACT_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-contract-regression.lisp"
'
run_case "run-bootstrap-v4-wave35-reflection-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE35_REFLECTION_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/REFLECTION.md"
'

run_case "run-bootstrap-v4-slice35-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE35_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE35.md"
  { echo "v4.slice35=1"; } >> "'"$V4_SLICE35_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave36-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE36_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE36_ADD31_ELF"'"
'

run_case "run-bootstrap-v4-wave36-orchestration-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE36_ORCHESTRATION_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-orchestration-bundle.lisp"
'
run_case "run-bootstrap-v4-wave36-dispatch-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE36_DISPATCH_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-dispatch.lisp"
'

run_case "run-bootstrap-v4-slice36-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE36_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE36.md"
  { echo "v4.slice36=1"; } >> "'"$V4_SLICE36_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave37-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE37_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE37_ADD32_ELF"'"
'

run_case "run-bootstrap-v4-wave37-gen5-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE37_GEN5_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-gen5-anchor.lisp"
'
run_case "run-bootstrap-v4-wave37-readme-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE37_README_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/README.md"
'

run_case "run-bootstrap-v4-slice37-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE37_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE37.md"
  { echo "v4.slice37=1"; } >> "'"$V4_SLICE37_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave38-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE38_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE38_ADD33_ELF"'"
'
run_case "run-bootstrap-v4-wave38-aarch64-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE38_AARCH64_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-aarch64-aot-plan.lisp"
'
run_case "run-bootstrap-v4-wave38-slice10-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE38_SLICE10_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-slice10-ir-entry.lisp"
'
run_case "run-bootstrap-v4-slice38-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE38_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE38.md"
  { echo "v4.slice38=1"; } >> "'"$V4_SLICE38_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave39-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE39_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE39_ADD34_ELF"'"
'
run_case "run-bootstrap-v4-wave39-irtable-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE39_IRTABLE_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-slice11-ir-table.lisp"
'
run_case "run-bootstrap-v4-wave39-words-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE39_WORDS_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-slice16-plan-words.lisp"
'
run_case "run-bootstrap-v4-slice39-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE39_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE39.md"
  { echo "v4.slice39=1"; } >> "'"$V4_SLICE39_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave40-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE40_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE40_ADD35_ELF"'"
'
run_case "run-bootstrap-v4-wave40-onion-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE40_ONION_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-onion-tick.lisp"
'
run_case "run-bootstrap-v4-wave40-terminal-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE40_TERMINAL_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/DECISION.md"
'
run_case "run-bootstrap-v4-slice40-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE40_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE40.md"
  { echo "v4.slice40=1"; } >> "'"$V4_SLICE40_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave41-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE41_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE41_ADD36_ELF"'"
'
run_case "run-bootstrap-v4-wave41-emit-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE41_EMIT_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-codegen-kickoff.lisp"
'
run_case "run-bootstrap-v4-wave41-slice18-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE41_SLICE18_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-slice18-ir-table-op.lisp"
'
run_case "run-bootstrap-v4-slice41-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE41_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE41.md"
  { echo "v4.slice41=1"; } >> "'"$V4_SLICE41_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave42-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE42_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE42_ADD37_ELF"'"
'
run_case "run-bootstrap-v4-wave42-squad-s3-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE42_SQUAD_S3_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-s3-supervise-once.lisp"
'
run_case "run-bootstrap-v4-wave42-assess-bundle-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE42_ASSESS_BUNDLE_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-assess-once.lisp"
'
run_case "run-bootstrap-v4-slice42-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE42_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE42.md"
  { echo "v4.slice42=1"; } >> "'"$V4_SLICE42_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave43-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE43_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE43_ADD38_ELF"'"
'
run_case "run-bootstrap-v4-wave43-mindmap-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE43_MINDMAP_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/MINDMAP.md"
'
run_case "run-bootstrap-v4-wave43-progress-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE43_PROGRESS_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/PROGRESS.md"
'
run_case "run-bootstrap-v4-slice43-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE43_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE43.md"
  { echo "v4.slice43=1"; } >> "'"$V4_SLICE43_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave44-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE44_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE44_ADD39_ELF"'"
'
run_case "run-bootstrap-v4-wave44-ir-words-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE44_IR_WORDS_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/v4-ir-words-v2.txt"
'
run_case "run-bootstrap-v4-wave44-build-graph-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE44_BUILD_GRAPH_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-build-graph-wave27.lisp"
'
run_case "run-bootstrap-v4-slice44-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE44_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE44.md"
  { echo "v4.slice44=1"; } >> "'"$V4_SLICE44_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave45-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE45_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE45_ADD40_ELF"'"
'
run_case "run-bootstrap-v4-wave45-gen5-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE45_GEN5_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-gen5-via-gen2-anchor.lisp"
'
run_case "run-bootstrap-v4-wave45-terminal-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE45_TERMINAL_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/COMPLETE-SCOPED.md"
'
run_case "run-bootstrap-v4-slice45-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE45_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE45.md"
  { echo "v4.slice45=1"; } >> "'"$V4_SLICE45_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave46-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE46_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE46_ADD41_ELF"'"
'
run_case "run-bootstrap-v4-wave46-kickoff-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE46_KICKOFF_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-kickoff.lisp"
'
run_case "run-bootstrap-v4-wave46-evidence-matrix-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE46_EVIDENCE_MATRIX_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-evidence-matrix.lisp"
'
run_case "run-bootstrap-v4-slice46-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE46_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE46.md"
  { echo "v4.slice46=1"; } >> "'"$V4_SLICE46_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave47-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE47_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE47_ADD42_ELF"'"
'
run_case "run-bootstrap-v4-wave47-supervise-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE47_SUPERVISE_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-supervise-chain.lisp"
'
run_case "run-bootstrap-v4-wave47-commander-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE47_COMMANDER_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-squad-commander-tick.lisp"
'
run_case "run-bootstrap-v4-slice47-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE47_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE47.md"
  { echo "v4.slice47=1"; } >> "'"$V4_SLICE47_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave48-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE48_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE48_ADD43_ELF"'"
'
run_case "run-bootstrap-v4-wave48-manifest-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE48_MANIFEST_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/v4-plan-manifest-v1.lisp"
'
run_case "run-bootstrap-v4-wave48-contract-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE48_CONTRACT_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v4-contract-regression.lisp"
'
run_case "run-bootstrap-v4-slice48-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE48_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE48.md"
  { echo "v4.slice48=1"; } >> "'"$V4_SLICE48_EVIDENCE"'"
'

run_case "run-bootstrap-v4-wave49-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE49_DIFFUSION_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.verified=plan-lisp-v1-full"
  test -f "'"$V4_SLICE49_ADD44_ELF"'"
'
run_case "run-bootstrap-v4-wave49-postv4-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE49_POSTV4_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/POST-V4.md"
'
run_case "run-bootstrap-v4-wave49-lisp-only-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_WAVE49_LISP_ONLY_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/LISP-ONLY.md"
'
run_case "run-bootstrap-v4-slice49-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE49_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE49.md"
  { echo "v4.slice49=1"; } >> "'"$V4_SLICE49_EVIDENCE"'"
'
run_case "run-bootstrap-v4-slice16-plan-words-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE16_PLAN_WORDS_SRC"'" 2>&1) || true
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.source=plan-words-v1"
  printf "%s
" "$out" | grep -q "aarch64.emit.ir.table.version=v5"
  test -f "'"$V4_SLICE16_ADD19_ELF"'"
'
run_case "run-bootstrap-v4-squad-mindmap-tick-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SQUAD_MINDMAP_TICK_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/MINDMAP.md"
'
run_case "run-bootstrap-v4-slice16-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE16_EVIDENCE_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/v4/SLICE16.md"
  { echo "v4.slice16=1"; } >> "'"$V4_SLICE16_EVIDENCE"'"
'
run_case "run-bootstrap-v4-terminal-build-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && test -f "'"$BOOTSTRAP_REPORT"'"
  pass=$(grep -E "^build\.pass=" "'"$BOOTSTRAP_REPORT"'" | tail -1 | cut -d= -f2)
  test -n "$pass" && test "$pass" -ge 26
  test -f "'"$LAB_DIR"'/v4/DECISION.md"
  { echo "v4.terminal_build=1"; echo "v4.terminal_build.pass=$pass"; } >> "'"$V4_TERMINAL_EVIDENCE"'"
'
run_case "run-bootstrap-v4-slice6-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$BOOTSTRAP_V4_SLICE6_EVIDENCE_SRC"'" 2>&1) || true
  printf "%s\n" "$out"
  test -f "'"$LAB_DIR"'/v4/REFLECTION.md"
  {
    echo "v4.slice6=1"
    echo "v4.slice6_codegen_kickoff=1"
    echo "v4.slice6_plan=run-bootstrap-v4-slice6-evidence-plan"
  } >> "'"$V4_SLICE6_EVIDENCE"'"
'

# --- bootstrap-v25 native selfpack (pack-ape per plan) ---
V25_NATIVE_SELFPACK_COM="$NANO_JIT_COM"
if host_is_linux_x86_64 && [ -x "$NANO_JIT_DIR/nano-jit.x86_64" ]; then
  V25_PACKER="$NANO_JIT_DIR/nano-jit.x86_64"
  run_case "run-bootstrap-v25-native-selfpack-plan" \
    bash -c "cd \"$ROOT_DIR\" && \"$V25_PACKER\" run-bootstrap-plan \"$BOOTSTRAP_V25_NATIVE_SELFPACK_SRC\""
  if [ -f "$V25_NATIVE_SELFPACK_COM" ]; then
    run_case "pack-ape-v25-native-selfpack-output" test -f "$V25_NATIVE_SELFPACK_COM"
    run_case "inspect-ape-v25-native-selfpack" bash -c '
      out=$("'"$V25_PACKER"'" inspect-ape "'"$V25_NATIVE_SELFPACK_COM"'" 2>&1) || true
      printf "%s\n" "$out"
      printf "%s\n" "$out" | grep -q "inspect-ape.container=ape-v2"
    '
  else
    skip_case "pack-ape-v25-native-selfpack-output" "nano-jit.com missing after plan (expected pack-ape output)"
    skip_case "inspect-ape-v25-native-selfpack" "nano-jit.com missing after plan"
  fi
else
  skip_case "run-bootstrap-v25-native-selfpack-plan" "requires Linux x86_64 and nano-jit.x86_64 slice"
  skip_case "pack-ape-v25-native-selfpack-output" "requires Linux x86_64 and nano-jit.x86_64 slice"
  skip_case "inspect-ape-v25-native-selfpack" "requires Linux x86_64 and nano-jit.x86_64 slice"
fi

run_end_summary
run_case "squad-v4-wave12-practice-smoke" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" resume --reason run-sh-wave12 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "wave=1"
  ae=" --no-auto-exec"
  for role in commander engineer-a engineer-b reviewer; do
    out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" run-loop --role "$role" --once${ae} 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "run-loop role=$role"
  done
  {
    echo "v4.slice7_wave12_smoke=1"
  } >> "'"$V4_SLICE7_EVIDENCE"'"
'
run_case "squad-v4-wave11-practice-smoke" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" resume --reason run-sh-wave11 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "wave=1"
  ae=" --no-auto-exec"
  for role in commander engineer-a engineer-b reviewer; do
    out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" run-loop --role "$role" --once${ae} 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "run-loop role=$role"
  done
  {
    echo "v4.slice6_wave11_smoke=1"
  } >> "'"$V4_SLICE6_EVIDENCE"'"
'
run_case "squad-v4-wave10-practice-smoke" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" resume --reason run-sh-wave10 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$out" | grep -q "wave=1"
  ae=" --no-auto-exec"
  if [[ "${SQUAD_VERIFY:-}" = "1" ]]; then ae=" --no-auto-exec"; fi
  for role in commander engineer-a engineer-b reviewer; do
    out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" run-loop --role "$role" --once${ae} 2>&1) || true
    printf "%s\n" "$out"
    printf "%s\n" "$out" | grep -q "run-loop role=$role"
  done
  {
    echo "v4.slice5_wave10_smoke=1"
  } >> "'"$V4_SLICE5_EVIDENCE"'"
'
run_case "squad-v4-commander-complete-smoke" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" supervise --once 2>&1) || true
  assess=$("'"$SQUAD_SH"'" --catalog "'"$CATALOG_V4"'" assess 2>&1) || true
  printf "%s\n" "$out"
  printf "%s\n" "$assess"
  printf "%s\n" "$out" | grep -qE "outcome=complete|ready=True" || \
    printf "%s\n" "$assess" | grep -q "scoped_ready=True"
'
log ""
log "results.file=$RESULTS"

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
