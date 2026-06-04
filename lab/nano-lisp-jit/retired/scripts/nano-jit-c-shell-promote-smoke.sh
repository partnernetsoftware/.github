#!/usr/bin/env bash
# C release shell promote prep smoke — cosmocc honest skip; never rewrite manifest without rebuild.
# Standalone (not in nano-jit-c-gate.sh by default). Optional: NANO_C_SHELL_PROMOTE_BUILD=1 for full factory.
# Optional: NANO_BOOTSTRAP_COSMOCC=1 runs bootstrap-cosmocc.sh first (third_party/cosmocc symlink or download).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
if [ "${NANO_BOOTSTRAP_COSMOCC:-0}" = 1 ]; then
  bash "$ROOT/lab/nano-lisp-jit/retired/scripts/bootstrap-cosmocc.sh" || true
fi
LAB="$ROOT/lab/nano-lisp-jit"
RETIRED="$LAB/retired"
RUNNER_SRC="$RETIRED/archive-c/runner"
EMBED_C="$LAB/archive/c/embed/shell-script.lbin"
C_COM="$LAB/release/nano-lisp.com"
MAN="$LAB/release/manifest.txt"
HOST_BIN="$LAB/.build/nano-lisp-jit-host-shell-noarg"
cd "$ROOT"

discover_cosmo_bin() {
  if [ -n "${COSMO_BIN:-}" ]; then
    printf '%s\n' "$COSMO_BIN"
    return
  fi
  for tool in x86_64-unknown-cosmo-cc cosmocc; do
    if command -v "$tool" >/dev/null 2>&1; then
      dirname "$(command -v "$tool")"
      return
    fi
  done
  for dir in \
    "$ROOT/third_party/cosmocc/bin" \
    /opt/cosmocc/bin \
    /opt/cosmo/bin \
    /usr/local/cosmocc/bin \
    /usr/local/cosmo/bin; do
    if [ -x "$dir/x86_64-unknown-cosmo-cc" ]; then
      printf '%s\n' "$dir"
      return
    fi
  done
  printf '%s\n' "$ROOT/third_party/cosmocc/bin"
}

cosmocc_usable() {
  local dir="$1"
  [ -x "$dir/x86_64-unknown-cosmo-cc" ]
}

promote_smoke_source_grep() {
  grep -q 'cmd_shell_noarg' "$RUNNER_SRC/nano_main.c" || {
    echo "nano-jit-c-shell-promote-smoke=fail source_main"
    exit 1
  }
  grep -q 'cmd_shell_noarg' "$RUNNER_SRC/nano_shell_cli.c" || {
    echo "nano-jit-c-shell-promote-smoke=fail source_shell_cli"
    exit 1
  }
  echo "nano-jit-c-shell-promote-smoke=ok source_grep"
}

promote_smoke_host_cc_factory() {
  [ -f "$EMBED_C" ] || {
    echo "nano-jit-c-shell-promote-smoke=fail no_c_embed path=$EMBED_C"
    exit 1
  }
  if ! command -v cc >/dev/null 2>&1; then
    echo "nano-jit-c-shell-promote-smoke=skip host_cc_missing"
    return 0
  fi
  mkdir -p "$(dirname "$HOST_BIN")"
  cc -DNANO_LISP_JIT \
    -I "$ROOT/lab/lispjit-ir" \
    -I "$RUNNER_SRC" \
    -Os -s "$LAB/archive/c/runner/lispjit.c" \
    -ldl -o "$HOST_BIN"
  chmod +x "$HOST_BIN"
  log=$("$HOST_BIN" 2>&1) || true
  echo "$log" | grep -q 'shell.mode=embedded-lbin' || {
    echo "nano-jit-c-shell-promote-smoke=fail host_mode expected=embedded-lbin"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q "shell.lbin=lab/nano-lisp-jit/archive/c/embed/shell-script.lbin" || {
    echo "nano-jit-c-shell-promote-smoke=fail host_embed_path"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q 'nanolisp-shell-script-step1' || {
    echo "nano-jit-c-shell-promote-smoke=fail host_step1"
    echo "$log"
    exit 1
  }
  echo "$log" | grep -q 'ret=0' || {
    echo "nano-jit-c-shell-promote-smoke=fail host_ret"
    echo "$log"
    exit 1
  }
  echo "nano-jit-c-shell-promote-smoke=ok host_cc_factory artifact=$HOST_BIN"
}

echo "nano-jit-c-shell-promote-smoke=begin"

COSMO_DIR="$(discover_cosmo_bin)"
if ! cosmocc_usable "$COSMO_DIR"; then
  echo "nano-jit-c-shell-promote-smoke=skip cosmocc_missing dir=$COSMO_DIR"
  promote_smoke_source_grep
  promote_smoke_host_cc_factory
  echo "nano-jit-c-shell-promote-smoke=ok promote_prep=host_cc cosmocc=0"
  exit 0
fi
X86_CC="$COSMO_DIR/x86_64-unknown-cosmo-cc"
echo "nano-jit-c-shell-promote-smoke=ok cosmocc dir=$COSMO_DIR"

promote_smoke_source_grep

[ -x "$C_COM" ] || { echo "nano-jit-c-shell-promote-smoke=fail no_c_com"; exit 1; }
[ -f "$MAN" ] || { echo "nano-jit-c-shell-promote-smoke=fail no_manifest"; exit 1; }

MAN_BYTES=$(grep -E '^nano-lisp\.com\.bytes=' "$MAN" | head -1 | cut -d= -f2 | tr -d '[:space:]')
MAN_HASH=$(grep -E '^nano-lisp\.com\.fnv1a64=' "$MAN" | head -1 | cut -d= -f2 | tr -d '[:space:]')
COM_BYTES=$(wc -c <"$C_COM" | tr -d ' ')
COM_HASH=$("$C_COM" file-hash "$C_COM" 2>/dev/null | tail -1 | tr -d '[:space:]')
if [ "$COM_BYTES" != "$MAN_BYTES" ] || [ "$COM_HASH" != "$MAN_HASH" ]; then
  echo "nano-jit-c-shell-promote-smoke=fail manifest_parity com=$COM_BYTES/$COM_HASH man=$MAN_BYTES/$MAN_HASH"
  exit 1
fi
echo "nano-jit-c-shell-promote-smoke=ok manifest_parity bytes=$COM_BYTES"

if [ -z "${NANO_C_RELEASE_HAS_SHELL+x}" ]; then
  # shellcheck source=nanolisp-c-release-shell-probe.sh
  . "$ROOT/lab/nano-lisp-jit/retired/scripts/nanolisp-c-release-shell-probe.sh"
  nanolisp_c_release_shell_probe_apply >/dev/null
fi

log=$("$C_COM" 2>&1) || rc=$?
rc=${rc:-0}
if [ "${NANO_C_RELEASE_HAS_SHELL}" = 1 ]; then
  echo "$log" | grep -q 'shell.mode=' || {
    echo "nano-jit-c-shell-promote-smoke=fail release_shell_mode"
    echo "$log"
    exit 1
  }
  echo "nano-jit-c-shell-promote-smoke=ok release_has_shell=1"
else
  if [ "$rc" -ne 2 ]; then
    echo "nano-jit-c-shell-promote-smoke=fail release_exit expected=2 actual=$rc"
    echo "$log"
    exit 1
  fi
  echo "$log" | grep -q 'usage:' || {
    echo "nano-jit-c-shell-promote-smoke=fail release_usage_gap"
    echo "$log"
    exit 1
  }
  echo "nano-jit-c-shell-promote-smoke=ok release_gap usage_exit=2"
fi

if [ "${NANO_C_SHELL_PROMOTE_BUILD:-0}" = 1 ]; then
  NANO_C_GATE_FACTORY=1 bash "$LAB/build_nano_jit.sh"
  BUILD_COM="$LAB/.build/nano-jit/nano-jit.com"
  if [ ! -x "$BUILD_COM" ]; then
    BUILD_COM="$LAB/.build/nano-jit/nano-jit.x86_64"
  fi
  [ -x "$BUILD_COM" ] || {
    echo "nano-jit-c-shell-promote-smoke=fail factory_no_artifact"
    exit 1
  }
  log=$("$BUILD_COM" 2>&1) || rc=$?
  rc=${rc:-0}
  echo "$log" | grep -q 'shell.mode=' || {
    echo "nano-jit-c-shell-promote-smoke=fail factory_shell_mode rc=$rc"
    echo "$log"
    exit 1
  }
  echo "nano-jit-c-shell-promote-smoke=ok factory_build artifact=$BUILD_COM"
  echo "nano-jit-c-shell-promote-smoke=note manifest_unchanged promote_manual=v45-manifest-pin.sh"
else
  echo "nano-jit-c-shell-promote-smoke=skip factory_build_deferred reason=build_nano_jit_heavy set_NANO_C_SHELL_PROMOTE_BUILD=1"
fi

echo "nano-jit-c-shell-promote-smoke=ok cosmocc=1 promote_prep=1"
