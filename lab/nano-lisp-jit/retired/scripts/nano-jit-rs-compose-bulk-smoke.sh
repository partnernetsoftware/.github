#!/usr/bin/env bash
# nanolisp compose-15 bulk-scale smoke — modules-expand 925×15 → exit 42 + 154559B parity.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
EXP="$ROOT/lab/nano-lisp-jit/lisp/modules-expand"
THRESHOLD="${NANO_BULK_CODE_BYTES_THRESHOLD:-154000}"
EXPECTED="${NANO_BULK_CODE_BYTES_EXPECT:-154559}"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-compose-bulk-smoke=fail no_binary"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-compose-bulk-smoke=fail no_legacy_com"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-compose-bulk-smoke"
mkdir -p "$TMP"

# link order — profile compose-15link-bulk-scale (Wave82/Wave93)
SPECS=(
  "$EXP/26-bulk-main-expand.lisp:nano_tu_main:main"
  "$EXP/27-bulk-callee-expand.lisp:nano_tu_callee:callee"
  "$EXP/15-bulk-extra-expand.lisp:nano_lispjit_extra:extra"
  "$EXP/14-bulk-core-expand.lisp:nano_mod_core:core"
  "$EXP/13-bulk-text-expand.lisp:nano_mf_mod:mf"
  "$EXP/17-bulk-boot-expand.lisp:nano_mod_boot:boot"
  "$EXP/16-bulk-vm-expand.lisp:nano_mod_vm:vm"
  "$EXP/18-bulk-aot-expand.lisp:nano_mod_aot:aot"
  "$EXP/19-bulk-elf-expand.lisp:nano_mod_elf:elf"
  "$EXP/20-bulk-abi-expand.lisp:nano_mod_abi:abi"
  "$EXP/21-bulk-manifest-expand.lisp:nano_mod_manifest:manifest"
  "$EXP/22-bulk-run-expand.lisp:nano_mod_run:run"
  "$EXP/23-bulk-pack-expand.lisp:nano_mod_pack:pack"
  "$EXP/24-bulk-ape-expand.lisp:nano_mod_ape:ape"
  "$EXP/25-bulk-parse-expand.lisp:nano_mod_parse:parse"
)

RS_OBJS=()
COM_OBJS=()
for spec in "${SPECS[@]}"; do
  IFS=: read -r src sym tag <<<"$spec"
  rs_o="$TMP/${tag}.o"
  com_o="$TMP/${tag}-com.o"
  "$RS" compile-elf64-obj-code "$src" "$rs_o" "$sym" >/dev/null
  "$COM" compile-elf64-obj-code "$src" "$com_o" "$sym" >/dev/null
  RS_OBJS+=("$rs_o")
  COM_OBJS+=("$com_o")
done

LINKED="$TMP/bulk-linked.elf"
"$RS" link-elf64-exe "$LINKED" nano_tu_main "${RS_OBJS[@]}" >/dev/null
log=$("$RS" run-expect-exit "$LINKED" 42 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-compose-bulk-smoke=fail run"
  echo "$log"
  exit 1
}

rs_bytes=$("$RS" link-elf64-exe "$TMP/bulk-linked2.elf" nano_tu_main "${RS_OBJS[@]}" 2>&1 | sed -n 's/^link.code.bytes=//p')
com_bytes=$("$COM" link-elf64-exe "$TMP/bulk-com.elf" nano_tu_main "${COM_OBJS[@]}" 2>&1 | sed -n 's/^link.code.bytes=//p')
[ "$rs_bytes" = "$com_bytes" ] || {
  echo "nano-jit-rs-compose-bulk-smoke=fail code_bytes rs=$rs_bytes com=$com_bytes"
  exit 1
}
[ "${rs_bytes:-0}" -ge "$THRESHOLD" ] || {
  echo "nano-jit-rs-compose-bulk-smoke=fail below_threshold bytes=$rs_bytes threshold=$THRESHOLD"
  exit 1
}
[ "$rs_bytes" = "$EXPECTED" ] || {
  echo "nano-jit-rs-compose-bulk-smoke=fail expected_bytes rs=$rs_bytes expected=$EXPECTED"
  exit 1
}

echo "nano-jit-rs-compose-bulk-smoke=ok link.code.bytes=$rs_bytes threshold=$THRESHOLD"
