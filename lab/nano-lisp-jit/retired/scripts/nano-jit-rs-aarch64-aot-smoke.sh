#!/usr/bin/env bash
# nanolisp aarch64 VM/AOT smoke — pure-blob lowering + build-slice-lisp + optional qemu.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
CORE="$ROOT/lab/nano-lisp-jit/lisp/core"
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-aarch64-aot-smoke"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-aarch64-aot-smoke=fail no_binary"; exit 1; }
mkdir -p "$TMP"

MIN_LISP="$CORE/nano-jit-slice-min.lisp"
IR_LISP="$CORE/nano-jit-slice-ir-exit-v1.lisp"
MIN_ELF="$TMP/min-vm-aot.elf"
IR_ELF="$TMP/ir-vm-aot.elf"
BSL_ELF="$TMP/bsl-min.elf"

compile_log=$("$RS" compile-aarch64-code "$MIN_LISP" "$MIN_ELF" 2>&1) || true
echo "$compile_log" | grep -q 'aarch64.emit.profile=vm-aot-v1' || {
  echo "nano-jit-rs-aarch64-aot-smoke=fail compile_profile"
  echo "$compile_log"
  exit 1
}
log=$("$RS" compile-aarch64-code "$MIN_LISP" "$TMP/min2.elf" 2>&1) || true
echo "$log" | grep -q 'aarch64.emit.profile=vm-aot-v1' || {
  echo "nano-jit-rs-aarch64-aot-smoke=fail compile_profile"
  echo "$log"
  exit 1
}

BSL_PLAN="$TMP/bsl-min-plan.lisp"
cat >"$BSL_PLAN" <<EOF
(bootstrap
  (build-slice-lisp "$MIN_LISP" "$BSL_ELF" "aarch64"))
EOF
log=$("$RS" run-bootstrap-plan "$BSL_PLAN" 2>&1) || true
echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-aarch64-aot-smoke=fail bsl_plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'build-slice-lisp.mode=aarch64-vm-aot-emit' || {
  echo "nano-jit-rs-aarch64-aot-smoke=fail build_slice_mode"
  echo "$log"
  exit 1
}

IR_PLAN="$TMP/bsl-ir-plan.lisp"
cat >"$IR_PLAN" <<EOF
(bootstrap
  (build-slice-lisp "$IR_LISP" "$IR_ELF" "aarch64"))
EOF
log=$("$RS" run-bootstrap-plan "$IR_PLAN" 2>&1) || true
echo "$log" | grep -q 'build-slice-lisp.mode=aarch64-vm-aot-emit' || {
  echo "nano-jit-rs-aarch64-aot-smoke=fail ir_build_slice"
  echo "$log"
  exit 1
}

min_logical=$(sed -n 's/^compile.aarch64.bytes=//p' <<<"$compile_log")
[ "${min_logical:-0}" -gt 0 ] && [ "${min_logical:-999}" -lt 1024 ] || {
  echo "nano-jit-rs-aarch64-aot-smoke=fail slim_logical=$min_logical"
  exit 1
}

qemu=""
for c in /usr/bin/qemu-aarch64-static /usr/bin/qemu-aarch64; do
  [ -x "$c" ] && qemu="$c" && break
done
if [ -n "$qemu" ]; then
  rc=$("$qemu" "$MIN_ELF"; echo $?)
  [ "$rc" = "42" ] || {
    echo "nano-jit-rs-aarch64-aot-smoke=fail qemu_min exit=$rc"
    exit 1
  }
  echo "nano-jit-rs-aarch64-aot-smoke=ok qemu=1 min_logical=$min_logical"
else
  echo "nano-jit-rs-aarch64-aot-smoke=ok qemu=0 min_logical=$min_logical"
fi
