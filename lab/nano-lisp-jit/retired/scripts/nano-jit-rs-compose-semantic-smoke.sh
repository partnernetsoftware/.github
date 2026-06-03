#!/usr/bin/env bash
# nanolisp compose-15 semantic ladder smoke — 8|32|64|154 profile → exit 42 + code parity vs C COM.
# Usage: nano-jit-rs-compose-semantic-smoke.sh <8|32|64|154>
set -euo pipefail
LADDER="${1:-}"
case "$LADDER" in
  8|32|64|154) ;;
  *)
    echo "nano-jit-rs-compose-semantic-smoke=fail bad_ladder ladder=$LADDER (use 8|32|64|154)"
    exit 1
    ;;
esac

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
CORE="$ROOT/lab/nano-lisp-jit/lisp/core"
MODS="$ROOT/lab/nano-lisp-jit/lisp/modules"
SEM="$ROOT/lab/nano-lisp-jit/lisp/modules-semantic"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-compose-semantic-${LADDER}k-smoke=fail no_binary"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-compose-semantic-${LADDER}k-smoke=fail no_legacy_com"; exit 1; }

case "$LADDER" in
  8)
    THRESHOLD="${NANO_SEMANTIC_CODE_BYTES_THRESHOLD:-8000}"
    MAIN="$SEM/tu-main-8k.lisp"
    EXPECT="${NANO_SEMANTIC_8K_CODE_BYTES_EXPECT:-}"
    ;;
  32)
    THRESHOLD="${NANO_SEMANTIC_32K_CODE_BYTES_THRESHOLD:-32000}"
    MAIN="$SEM/tu-main-32k.lisp"
    EXPECT="${NANO_SEMANTIC_32K_CODE_BYTES_EXPECT:-32001}"
    ;;
  64)
    THRESHOLD="${NANO_SEMANTIC_64K_CODE_BYTES_THRESHOLD:-64000}"
    MAIN="$SEM/tu-main-64k.lisp"
    EXPECT="${NANO_SEMANTIC_64K_CODE_BYTES_EXPECT:-64066}"
    ;;
  154)
    THRESHOLD="${NANO_SEMANTIC_154K_CODE_BYTES_THRESHOLD:-154000}"
    MAIN="$SEM/tu-main-154k.lisp"
    EXPECT="${NANO_SEMANTIC_154K_CODE_BYTES_EXPECT:-155036}"
    ;;
esac

TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-compose-semantic-${LADDER}k-smoke"
mkdir -p "$TMP"

SPECS=(
  "$MAIN:nano_tu_main:main"
  "$CORE/lisp-tu-callee.lisp:nano_tu_callee:callee"
  "$MODS/01-runtime-extra.lisp:nano_lispjit_extra:extra"
  "$SEM/core-semantic-40.lisp:nano_mod_core:core"
  "$SEM/mf-semantic-40.lisp:nano_mf_mod:mf"
  "$MODS/03-bootstrap-stub.lisp:nano_mod_boot:boot"
  "$MODS/04-vm.lisp:nano_mod_vm:vm"
  "$MODS/05-aot.lisp:nano_mod_aot:aot"
  "$MODS/06-elf.lisp:nano_mod_elf:elf"
  "$MODS/07-abi.lisp:nano_mod_abi:abi"
  "$MODS/08-manifest.lisp:nano_mod_manifest:manifest"
  "$MODS/09-run.lisp:nano_mod_run:run"
  "$MODS/10-pack.lisp:nano_mod_pack:pack"
  "$MODS/11-ape.lisp:nano_mod_ape:ape"
  "$MODS/12-parse.lisp:nano_mod_parse:parse"
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

LINKED="$TMP/semantic-${LADDER}k-linked.elf"
"$RS" link-elf64-exe "$LINKED" nano_tu_main "${RS_OBJS[@]}" >/dev/null
log=$("$RS" run-expect-exit "$LINKED" 42 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-compose-semantic-${LADDER}k-smoke=fail run"
  echo "$log"
  exit 1
}

rs_bytes=$("$RS" link-elf64-exe "$TMP/semantic-${LADDER}k-linked2.elf" nano_tu_main "${RS_OBJS[@]}" 2>&1 | sed -n 's/^link.code.bytes=//p')
com_bytes=$("$COM" link-elf64-exe "$TMP/semantic-${LADDER}k-com.elf" nano_tu_main "${COM_OBJS[@]}" 2>&1 | sed -n 's/^link.code.bytes=//p')
[ "$rs_bytes" = "$com_bytes" ] || {
  echo "nano-jit-rs-compose-semantic-${LADDER}k-smoke=fail code_bytes rs=$rs_bytes com=$com_bytes"
  exit 1
}
[ "${rs_bytes:-0}" -ge "$THRESHOLD" ] || {
  echo "nano-jit-rs-compose-semantic-${LADDER}k-smoke=fail below_threshold bytes=$rs_bytes threshold=$THRESHOLD"
  exit 1
}
if [ -n "$EXPECT" ] && [ "$rs_bytes" != "$EXPECT" ]; then
  echo "nano-jit-rs-compose-semantic-${LADDER}k-smoke=fail expected_bytes rs=$rs_bytes expected=$EXPECT"
  exit 1
fi

echo "nano-jit-rs-compose-semantic-${LADDER}k-smoke=ok link.code.bytes=$rs_bytes threshold=$THRESHOLD"
