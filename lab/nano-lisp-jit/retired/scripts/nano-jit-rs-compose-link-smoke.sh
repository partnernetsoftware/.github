#!/usr/bin/env bash
# nanolisp compose-Nlink smoke — N TU obj compile + link → exit 42 + code parity vs C COM.
# Usage: nano-jit-rs-compose-link-smoke.sh <5|8|15>
set -euo pipefail
N="${1:-}"
case "$N" in
  5|8|15) ;;
  *)
    echo "nano-jit-rs-compose-link-smoke=fail bad_n n=$N (use 5|8|15)"
    exit 1
    ;;
esac

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
CORE="$ROOT/lab/nano-lisp-jit/lisp/core"
MODS="$ROOT/lab/nano-lisp-jit/lisp/modules"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-compose-link-smoke=fail no_binary n=$N"; exit 1; }
[ -x "$COM" ] || { echo "nano-jit-rs-compose-link-smoke=fail no_legacy_com n=$N"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-compose${N}-smoke"
mkdir -p "$TMP"

# link order matches bootstrap-v45-compose-link-15chain.lisp / nano_bootstrap.c
# format: rel_path:symbol:tag
ALL=(
  "$CORE/lisp-tu-main.lisp:nano_tu_main:main"
  "$CORE/lisp-tu-callee.lisp:nano_tu_callee:callee"
  "$MODS/01-runtime-extra.lisp:nano_lispjit_extra:extra"
  "$MODS/00-runtime-core.lisp:nano_mod_core:core"
  "$CORE/multi-func.lisp:nano_mf_mod:mf"
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

SLICE=("${ALL[@]:0:$N}")
RS_OBJS=()
COM_OBJS=()

for spec in "${SLICE[@]}"; do
  IFS=: read -r src sym tag <<<"$spec"
  rs_o="$TMP/${tag}.o"
  com_o="$TMP/${tag}-com.o"
  "$RS" compile-elf64-obj-code "$src" "$rs_o" "$sym" >/dev/null
  "$COM" compile-elf64-obj-code "$src" "$com_o" "$sym" >/dev/null
  RS_OBJS+=("$rs_o")
  COM_OBJS+=("$com_o")
done

LINKED="$TMP/compose${N}-linked.elf"
"$RS" link-elf64-exe "$LINKED" nano_tu_main "${RS_OBJS[@]}" >/dev/null
log=$("$RS" run-expect-exit "$LINKED" 42 2>&1) || true
echo "$log" | grep -q 'run-expect-exit.ok=1' || {
  echo "nano-jit-rs-compose-link-smoke=fail run n=$N"
  echo "$log"
  exit 1
}

rs_bytes=$("$RS" link-elf64-exe "$TMP/compose${N}-linked2.elf" nano_tu_main "${RS_OBJS[@]}" 2>&1 | sed -n 's/^link.code.bytes=//p')
com_bytes=$("$COM" link-elf64-exe "$TMP/compose${N}-com.elf" nano_tu_main "${COM_OBJS[@]}" 2>&1 | sed -n 's/^link.code.bytes=//p')
[ "$rs_bytes" = "$com_bytes" ] || {
  echo "nano-jit-rs-compose-link-smoke=fail code_bytes n=$N rs=$rs_bytes com=$com_bytes"
  exit 1
}

echo "nano-jit-rs-compose${N}-smoke=ok link.code.bytes=$rs_bytes modules=$N"
