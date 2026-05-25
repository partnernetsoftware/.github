#!/usr/bin/env bash
# Wave12: tier5 广度扩散 — 四轨并行归档 16× nano_*.c + 单轮收敛.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
BATCH="$ROOT/lab/nano-lisp-jit/tools/v45-archive-runner-batch.sh"
cd "$ROOT"
fail=0
echo "v45-wave12-tier5-converge=begin"

bash "$(dirname "$0")/v45-wave11-tier5-converge.sh" || fail=$((fail + 1))

# 四轨并发归档（广度扩散，勿逐文件串行）
pids=()
bash "$BATCH" A nano_abi.c nano_util.c nano_manifest.c nano_main.c &
pids+=($!)
bash "$BATCH" B nano_lisp_parse.c nano_blob_vm.c nano_compile_cli.c nano_libc_resolve.c &
pids+=($!)
bash "$BATCH" C nano_elf64.c nano_cc.c nano_genesis_pin.c nano_aot_x86.c &
pids+=($!)
bash "$BATCH" D nano_ape.c nano_pack_app.c nano_run_cli.c nano_compile_elf64_cli.c &
pids+=($!)
for pid in "${pids[@]}"; do
  wait "$pid" || fail=$((fail + 1))
done

COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$COM" ]; then
  plans=(track-a-anchor track-b-anchor track-c-anchor track-d-anchor)
  pids=()
  for p in "${plans[@]}"; do
    (
      if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-wave12-$p.lisp" >/dev/null; then
        echo "v45-wave12-tier5-converge=ok plan=$p"
      else
        echo "v45-wave12-tier5-converge=fail plan=$p"
        exit 1
      fi
    ) &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do
    wait "$pid" || fail=$((fail + 1))
  done
  for p in diffuse-global rollup verify-smoke; do
    if "$COM" run-bootstrap-plan "lab/nano-lisp-jit/samples/bootstrap-v45-wave12-$p.lisp" >/dev/null; then
      echo "v45-wave12-tier5-converge=ok plan=$p"
    else
      echo "v45-wave12-tier5-converge=fail plan=$p"
      fail=$((fail + 1))
    fi
  done
fi

c_ir=$(find "$ROOT/lab/lispjit-ir" -name '*.c' ! -type l 2>/dev/null | wc -l)
c_arch=$(find "$ROOT/lab/nano-lisp-jit/archive/runner" -name '*.c' ! -type l 2>/dev/null | wc -l)
symlinks=$(find "$ROOT/lab/lispjit-ir" -name '*.c' -type l 2>/dev/null | wc -l)
n=$(ls -1 lab/nano-lisp-jit/samples/bootstrap-v45-*.lisp 2>/dev/null | wc -l)
{
  echo "v45.wave12.diffuse=1"
  echo "v45.wave12.parallel=4"
  echo "v45.wave12.rollup=1"
  echo "v45.wave12.plans=$n"
  echo "v45.tier5.nano_tu_archived=16"
  echo "v45.tier5.archive_symlinks=$symlinks"
  echo "v45.physical.inventory=1"
  echo "v45.honest.tier5.open=1"
  echo "v45.physical.zero_c=0"
  echo "v45.physical.lispjit_ir_c_files=$c_ir"
  echo "v45.physical.archive_runner_c_files=$c_arch"
} >>"$EV"
echo "v45-wave12-tier5-converge=done lispjit_ir_c=$c_ir symlinks=$symlinks archive_runner=$c_arch fail=$fail"
exit $fail
