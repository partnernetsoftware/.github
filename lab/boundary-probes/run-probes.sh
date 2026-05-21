#!/usr/bin/env bash
# Boundary probes for nano-lisp-jit: observe pass/fail and document limits.
set -uo pipefail
PROBE_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../_nano_common.sh
source "$PROBE_DIR/../_nano_common.sh"
RUNNER="$(nano_runner)"
BUILD="$PROBE_DIR/.build"
RESULTS="$PROBE_DIR/RESULTS.md"
mkdir -p "$BUILD"
HOST="$(uname -m)"

log() { printf '%s\n' "$*"; }

record() {
  printf '| %s | %s | %s | %s |\n' "$1" "$2" "$3" "$4" >> "$RESULTS.body"
}

probe_compile_run() {
  local id="$1" src="$2" expect="$3"
  local blob="$BUILD/${id}.lbin"
  local compile_rc=0 run_rc=0
  if "$RUNNER" compile "$src" "$blob" >/dev/null 2>&1; then
    compile_rc=0
  else
    compile_rc=$?
  fi
  if [ "$compile_rc" -ne 0 ]; then
    record "$id" "compile" "fail:${compile_rc}" "$expect"
    return 0
  fi
  if "$RUNNER" run "$blob" >/dev/null 2>&1; then
    run_rc=0
  else
    run_rc=$?
  fi
  if [ "$run_rc" -eq 0 ]; then
    record "$id" "compile+run" "ok" "$expect"
  else
    record "$id" "compile+run" "fail:${run_rc}" "$expect"
  fi
}

probe_compile_expect_fail() {
  local id="$1" src="$2"
  local blob="$BUILD/${id}.lbin"
  if "$RUNNER" compile "$src" "$blob" >/dev/null 2>&1; then
    record "$id" "compile" "unexpected_ok" "fail"
  else
    local rc=$?
    record "$id" "compile" "fail:${rc}" "fail"
  fi
}

probe_resolve_run() {
  local id="$1" src="$2" expect="$3"
  local blob="$BUILD/${id}.lbin"
  if ! "$RUNNER" compile "$src" "$blob" >/dev/null 2>&1; then
    record "$id" "compile" "fail" "$expect"
    return 0
  fi
  if ! "$RUNNER" resolve --quiet "$blob" >/dev/null 2>&1; then
    record "$id" "resolve" "fail" "$expect"
    return 0
  fi
  if "$RUNNER" run "$blob" >/dev/null 2>&1; then
    record "$id" "resolve+run" "ok" "$expect"
  else
    local rc=$?
    record "$id" "resolve+run" "fail:${rc}" "$expect"
  fi
}

probe_aot_code() {
  local id="$1" src="$2" expect="$3"
  local blob="$BUILD/${id}.lbin"
  local elf="$BUILD/${id}.elf"
  if [ "$HOST" != "x86_64" ] && [ "$HOST" != "amd64" ]; then
    record "$id" "compile-elf64-code" "skip(non-x86_64)" "$expect"
    return 0
  fi
  if ! "$RUNNER" compile "$src" "$blob" >/dev/null 2>&1; then
    record "$id" "compile" "fail" "$expect"
    return 0
  fi
  if ! "$RUNNER" compile-elf64-code "$src" "$elf" >/dev/null 2>&1; then
    record "$id" "compile-elf64-code" "fail" "$expect"
    return 0
  fi
  if "$RUNNER" run-expect-exit "$elf" -9223372036854775808 >/dev/null 2>&1; then
    record "$id" "aot+run" "ok" "$expect"
  else
    # try exit 42 style if probe uses different code
    local rc=0
    "$RUNNER" run-expect-exit "$elf" 42 >/dev/null 2>&1 || rc=$?
    record "$id" "aot+run" "exit_check(rc=$rc)" "$expect"
  fi
}

probe_compile_elf_expect_fail() {
  local id="$1" src="$2"
  local elf="$BUILD/${id}.elf"
  if [ "$HOST" != "x86_64" ] && [ "$HOST" != "amd64" ]; then
    record "$id" "compile-elf64-code" "skip" "fail"
    return 0
  fi
  if "$RUNNER" compile-elf64-code "$src" "$elf" >/dev/null 2>&1; then
    record "$id" "compile-elf64-code" "unexpected_ok" "fail"
  else
    local rc=$?
    record "$id" "compile-elf64-code" "fail:${rc}" "fail"
  fi
}

: > "$RESULTS.body"
log "runner=$RUNNER"
log "host=$HOST"
log "date=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

probe_compile_run "empty-main" "$PROBE_DIR/probes/empty-main.lisp" "pass"
probe_compile_run "i64-extremes" "$PROBE_DIR/probes/i64-extremes.lisp" "pass"
probe_compile_run "deep-branch-chain" "$PROBE_DIR/probes/deep-branch-chain.lisp" "pass"
probe_compile_expect_fail "multi-func-lbin" "$PROBE_DIR/probes/multi-func-chain.lisp"
probe_compile_run "branch-label-not-barrier" "$PROBE_DIR/probes/branch-label-not-barrier.lisp" "fail_run"
probe_compile_run "ptr-arith-large-offset" "$PROBE_DIR/probes/ptr-arith-large-offset.lisp" "pass"
probe_compile_run "many-imports-resolve" "$PROBE_DIR/probes/many-imports-resolve.lisp" "pass"
probe_compile_run "many-ops-u64" "$PROBE_DIR/probes/many-ops-u64.lisp" "pass"

probe_compile_expect_fail "duplicate-label-bad" "$PROBE_DIR/probes/duplicate-label-bad.lisp"
probe_compile_expect_fail "missing-main-bad" "$PROBE_DIR/probes/missing-main-bad.lisp"

probe_resolve_run "unknown-import-bad" "$PROBE_DIR/probes/unknown-import-bad.lisp" "resolve_fail"

# wrong ret: may fail at compile-elf64 or run
probe_compile_run "call-wrong-ret-bad" "$PROBE_DIR/probes/call-wrong-ret-bad.lisp" "fail_or_misrun"
probe_compile_elf_expect_fail "call-wrong-ret-aot" "$PROBE_DIR/probes/call-wrong-ret-bad.lisp"

probe_compile_run "aot-i64-extremes-vm" "$PROBE_DIR/probes/aot-i64-extremes.lisp" "pass"
probe_compile_run "i64-aot-unsupported-vm" "$PROBE_DIR/probes/i64-aot-unsupported.lisp" "pass"

if [ "$HOST" = "x86_64" ] || [ "$HOST" = "amd64" ]; then
  exe="$BUILD/multi-func-chain.elf"
  if "$RUNNER" compile-elf64-exe "$PROBE_DIR/probes/multi-func-chain.lisp" "$exe" nano_probe_multi >/dev/null 2>&1 && \
     "$RUNNER" run-expect-exit "$exe" 6 >/dev/null 2>&1; then
    record "multi-func-chain-aot" "compile-elf64-exe+run" "ok" "pass"
  else
    record "multi-func-chain-aot" "compile-elf64-exe+run" "fail" "pass"
  fi
  blob="$BUILD/many-ops-u64.lbin"
  elf="$BUILD/many-ops-u64.elf"
  src="$PROBE_DIR/probes/many-ops-u64.lisp"
  if "$RUNNER" compile "$src" "$blob" >/dev/null 2>&1 && \
     "$RUNNER" aot-elf64-code "$blob" "$elf" >/dev/null 2>&1 && \
     "$RUNNER" run-expect-exit "$elf" 30 >/dev/null 2>&1; then
    record "many-ops-u64-aot" "aot-elf64-code+run" "ok" "pass"
  else
    record "many-ops-u64-aot" "aot-elf64-code+run" "fail" "pass"
  fi
  src42="$PROBE_DIR/probes/i64-aot-unsupported.lisp"
  blob42="$BUILD/i64-42.lbin"
  if "$RUNNER" compile "$src42" "$blob42" >/dev/null 2>&1 && \
     "$RUNNER" compile-elf64-code "$src42" "$BUILD/i64-42.elf" >/dev/null 2>&1 && \
     "$RUNNER" run-expect-exit "$BUILD/i64-42.elf" 42 >/dev/null 2>&1; then
    record "i64-42-codegen" "compile-elf64+run" "ok" "pass"
  else
    record "i64-42-codegen" "compile-elf64+run" "fail" "pass"
  fi
  srcmin="$PROBE_DIR/probes/aot-i64-extremes.lisp"
  blobmin="$BUILD/i64-min.lbin"
  if "$RUNNER" compile "$srcmin" "$blobmin" >/dev/null 2>&1; then
    if "$RUNNER" compile-elf64-code "$srcmin" "$BUILD/i64-min.elf" >/dev/null 2>&1; then
      record "i64-min-codegen" "compile-elf64-code" "unexpected_ok" "fail"
    else
      record "i64-min-codegen" "compile-elf64-code" "unsupported_source" "fail"
    fi
    if "$RUNNER" aot-elf64-code "$blobmin" "$BUILD/i64-min-aot.elf" >/dev/null 2>&1; then
      record "i64-min-aot-blob" "aot-elf64-code" "unexpected_ok" "fail"
    else
      record "i64-min-aot-blob" "aot-elf64-code" "unsupported_blob" "fail"
    fi
  fi
fi

{
  echo "# nano-lisp-jit 能力边界探测"
  echo ""
  echo "自动生成：\`bash lab/boundary-probes/run-probes.sh\`"
  echo ""
  echo "| 探测 | 阶段 | 结果 | 预期 |"
  echo "|------|------|------|------|"
  cat "$RESULTS.body"
  echo ""
  echo "## 解读摘要"
  echo ""
  echo "见 \`BOUNDARY-NOTES.md\`（人工归纳的能力上限与差异）。"
} > "$RESULTS"

log "wrote $RESULTS"
