#!/usr/bin/env bash
# nanolisp NLCap v0 smoke — pack/inspect/run multi-tier capsule (.nlcap).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
CORE="$ROOT/lab/nano-lisp-jit/lisp/core"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-capsule-smoke=fail no_binary"; exit 1; }
TMP="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs-capsule-smoke"
mkdir -p "$TMP"

ARITH="$CORE/arithmetic.lisp"
LBIN="$TMP/arithmetic.lbin"
ELF="$TMP/arithmetic.elf"
CAP="$TMP/arithmetic.nlcap"

"$RS" compile "$ARITH" "$LBIN" >/dev/null
"$RS" compile-elf64-code "$ARITH" "$ELF" >/dev/null

# lbin + sbin + xbin tiers
"$RS" pack-capsule "$CAP" "$LBIN" --compress --xbin "$ELF" >/dev/null
log=$("$RS" inspect-capsule "$CAP" 2>&1)
echo "$log" | grep -q 'inspect-capsule.container=nlcap-v0' || {
  echo "nano-jit-rs-capsule-smoke=fail inspect"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'inspect-capsule.tier.0.kind=xbin' || {
  echo "nano-jit-rs-capsule-smoke=fail tier_order"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'inspect-capsule.tier.1.kind=sbin' || {
  echo "nano-jit-rs-capsule-smoke=fail sbin_tier"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'inspect-capsule.tier.2.kind=lbin' || {
  echo "nano-jit-rs-capsule-smoke=fail lbin_tier"
  echo "$log"
  exit 1
}

# abin tier — APE v2 multi-arch payload inside NLCap
X86="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
ARM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.aarch64"
APE="$TMP/arithmetic.ape"
CAP_ABIN="$TMP/arithmetic-abin.nlcap"
[ -f "$X86" ] && [ -f "$ARM" ] || { echo "nano-jit-rs-capsule-smoke=fail no_ape_slices"; exit 1; }
"$RS" pack-ape-bare "$APE" "$X86" "$ARM" >/dev/null
"$RS" pack-capsule "$CAP_ABIN" "$LBIN" --compress --xbin "$ELF" --abin "$APE" >/dev/null
log=$("$RS" inspect-capsule "$CAP_ABIN" 2>&1)
echo "$log" | grep -q 'inspect-capsule.tier.0.kind=abin' || {
  echo "nano-jit-rs-capsule-smoke=fail abin_tier"
  echo "$log"
  exit 1
}
log=$("$RS" run-capsule "$CAP_ABIN" --tier abin --expect 2 2>&1) || true
echo "$log" | grep -q 'run-capsule.tier=abin' || {
  echo "nano-jit-rs-capsule-smoke=fail abin_run"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-capsule.ok=1' || {
  echo "nano-jit-rs-capsule-smoke=fail abin_ok"
  echo "$log"
  exit 1
}
# auto prefers abin (priority 90) over xbin (100)
log=$("$RS" run-capsule "$CAP_ABIN" --expect 2 2>&1) || true
echo "$log" | grep -q 'run-capsule.tier=abin' || {
  echo "nano-jit-rs-capsule-smoke=fail auto_abin"
  echo "$log"
  exit 1
}

# xbin-only capsule (no abin)
log=$("$RS" run-capsule "$CAP" --expect 42 2>&1) || true
echo "$log" | grep -q 'run-capsule.tier=xbin' || {
  echo "nano-jit-rs-capsule-smoke=fail auto_xbin"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-capsule.ok=1' || {
  echo "nano-jit-rs-capsule-smoke=fail xbin_run"
  echo "$log"
  exit 1
}

# sbin → VM path
log=$("$RS" run-capsule "$CAP" --tier sbin 2>&1) || true
echo "$log" | grep -q 'run-capsule.tier=sbin' || {
  echo "nano-jit-rs-capsule-smoke=fail sbin_run"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'run-capsule.ok=1' || {
  echo "nano-jit-rs-capsule-smoke=fail sbin_ok"
  echo "$log"
  exit 1
}

# pack from .lisp directly
CAP2="$TMP/arithmetic2.nlcap"
"$RS" pack-capsule "$CAP2" "$ARITH" --compress >/dev/null
log=$("$RS" run-capsule "$CAP2" --tier lbin 2>&1) || true
echo "$log" | grep -q 'run-capsule.ok=1' || {
  echo "nano-jit-rs-capsule-smoke=fail lisp_pack"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-capsule-smoke=ok"
