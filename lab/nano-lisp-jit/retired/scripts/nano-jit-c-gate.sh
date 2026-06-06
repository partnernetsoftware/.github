#!/usr/bin/env bash
# C track gate — release/nano-lisp.com SSOT; no cosmocc required.
# Parity: manifest pin · verify-smoke plan · optional full factory (NANO_C_GATE_FACTORY=1).
# Optional shell promote prep (off by default): NANO_C_SHELL_PROMOTE=1 → nano-jit-c-shell-promote-smoke.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
MAN="$ROOT/lab/nano-lisp-jit/release/manifest.txt"
NANO_C="$ROOT/lab/nano-lisp-jit/archive/c/runner/lispjit.c"
VERIFY_PLAN="lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-smoke.lisp"
cd "$ROOT"
mkdir -p "$ROOT/lab/nano-lisp-jit/.build"

echo "nanolisp.c-gate=begin"

if [ ! -f "$NANO_C" ]; then
  echo "nanolisp.c-gate=fail missing_runner path=$NANO_C"
  exit 1
fi
echo "nanolisp.c-gate=ok runner_source bytes=$(wc -c <"$NANO_C" | tr -d ' ')"

if [ ! -x "$COM" ]; then
  echo "nanolisp.c-gate=fail missing_com path=$COM"
  exit 1
fi
COM_BYTES=$(wc -c <"$COM" | tr -d ' ')
COM_HASH=$("$COM" file-hash "$COM" 2>/dev/null | tail -1 | tr -d '[:space:]')
echo "nanolisp.c-gate=ok release_com bytes=$COM_BYTES fnv1a64=$COM_HASH"

if [ ! -f "$MAN" ]; then
  echo "nanolisp.c-gate=fail missing_manifest path=$MAN"
  exit 1
fi
MAN_BYTES=$(grep -E '^nano-lisp\.com\.bytes=' "$MAN" | head -1 | cut -d= -f2 | tr -d '[:space:]')
MAN_HASH=$(grep -E '^nano-lisp\.com\.fnv1a64=' "$MAN" | head -1 | cut -d= -f2 | tr -d '[:space:]')
if [ "$COM_BYTES" != "$MAN_BYTES" ] || [ "$COM_HASH" != "$MAN_HASH" ]; then
  echo "nanolisp.c-gate=fail manifest_parity com=$COM_BYTES/$COM_HASH man=$MAN_BYTES/$MAN_HASH"
  exit 1
fi
echo "nanolisp.c-gate=ok manifest_parity"

if ! "$COM" run-bootstrap-plan "$VERIFY_PLAN" >/tmp/nanolisp-c-gate-verify.log 2>&1; then
  tail -30 /tmp/nanolisp-c-gate-verify.log >&2 || true
  echo "nanolisp.c-gate=fail verify_smoke"
  exit 1
fi
echo "nanolisp.c-gate=ok verify_smoke"

bash "$RETIRED/v45-manifest-pin.sh" "$COM" >/dev/null
PIN_BYTES=$(grep -E '^nano-lisp\.com\.bytes=' "$MAN" | head -1 | cut -d= -f2 | tr -d '[:space:]')
if [ "$PIN_BYTES" != "$COM_BYTES" ]; then
  echo "nanolisp.c-gate=fail manifest_pin_roundtrip"
  exit 1
fi
if grep -qE '^nanolisp\.com\.bytes=' "$MAN" 2>/dev/null; then
  echo "nanolisp.c-gate=ok manifest_pin_preserved_rust=1"
else
  echo "nanolisp.c-gate=ok manifest_pin_preserved_rust=0"
fi

export NANO_C_GATE_RUNNING=1
bash "$RETIRED/nano-jit-com-lisp-only-smoke.sh"
bash "$RETIRED/nano-jit-c-codegen-158k-smoke.sh"
bash "$RETIRED/nano-jit-c-daily-unified-smoke.sh"
bash "$RETIRED/nano-jit-c-full-com-codegen-probe-smoke.sh"
bash "$RETIRED/nano-jit-c-full-com-pack-probe-smoke.sh"
bash "$RETIRED/nano-jit-c-full-com-regenesis-probe-smoke.sh"
bash "$RETIRED/nano-jit-c-shell-noarg-smoke.sh"
bash "$RETIRED/nano-jit-c-shell-fgets-smoke.sh"
bash "$RETIRED/nano-jit-c-shell-full-c-smoke.sh"

if [ "${NANO_C_GATE_FACTORY:-0}" = 1 ]; then
  bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh"
  echo "nanolisp.c-gate=ok factory_build"
fi

echo "nanolisp.c-gate=ok"
