#!/usr/bin/env bash
# nanolisp compose-15 semantic-unified smoke — tu-main-154k + sem-* ×14 → exit 42 + parity.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
SEM="$ROOT/lab/nano-lisp-jit/lisp/modules-semantic"
THRESHOLD="${NANO_SEMANTIC_UNIFIED_CODE_BYTES_THRESHOLD:-154000}"
EXPECTED="${NANO_SEMANTIC_UNIFIED_CODE_BYTES_EXPECT:-154017}"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-compose-semantic-unified-smoke=fail no_binary"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-compose-semantic-unified-smoke=fail no_legacy_com"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-compose-semantic-unified-smoke"
mkdir -p "$TMP"

SPECS=(
  "$SEM/tu-main-154k.lisp:nano_tu_main:main"
  "$SEM/sem-callee.lisp:nano_tu_callee:callee"
  "$SEM/sem-extra.lisp:nano_lispjit_extra:extra"
  "$SEM/sem-core.lisp:nano_mod_core:core"
  "$SEM/sem-mf.lisp:nano_mf_mod:mf"
  "$SEM/sem-boot.lisp:nano_mod_boot:boot"
  "$SEM/sem-vm.lisp:nano_mod_vm:vm"
  "$SEM/sem-aot.lisp:nano_mod_aot:aot"
  "$SEM/sem-elf.lisp:nano_mod_elf:elf"
  "$SEM/sem-abi.lisp:nano_mod_abi:abi"
  "$SEM/sem-manifest.lisp:nano_mod_manifest:manifest"
  "$SEM/sem-run.lisp:nano_mod_run:run"
  "$SEM/sem-pack.lisp:nano_mod_pack:pack"
  "$SEM/sem-ape.lisp:nano_mod_ape:ape"
  "$SEM/sem-parse.lisp:nano_mod_parse:parse"
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

LINKED="$TMP/unified-linked.elf"
"$RS" link-elf64-exe "$LINKED" nano_tu_main "${RS_OBJS[@]}" >/dev/null
log=$("$RS" run-expect-exit "$LINKED" 42 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-compose-semantic-unified-smoke=fail run"
  echo "$log"
  exit 1
}

rs_bytes=$("$RS" link-elf64-exe "$TMP/unified-linked2.elf" nano_tu_main "${RS_OBJS[@]}" 2>&1 | sed -n 's/^link.code.bytes=//p')
com_bytes=$("$COM" link-elf64-exe "$TMP/unified-com.elf" nano_tu_main "${COM_OBJS[@]}" 2>&1 | sed -n 's/^link.code.bytes=//p')
[ "$rs_bytes" = "$com_bytes" ] || {
  echo "nano-jit-rs-compose-semantic-unified-smoke=fail code_bytes rs=$rs_bytes com=$com_bytes"
  exit 1
}
[ "${rs_bytes:-0}" -ge "$THRESHOLD" ] || {
  echo "nano-jit-rs-compose-semantic-unified-smoke=fail below_threshold bytes=$rs_bytes threshold=$THRESHOLD"
  exit 1
}
[ "$rs_bytes" = "$EXPECTED" ] || {
  echo "nano-jit-rs-compose-semantic-unified-smoke=fail expected_bytes rs=$rs_bytes expected=$EXPECTED"
  exit 1
}

echo "nano-jit-rs-compose-semantic-unified-smoke=ok link.code.bytes=$rs_bytes threshold=$THRESHOLD"
