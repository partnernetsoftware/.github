#!/usr/bin/env bash
# Auto-detect C release shell UX (P2) — sets NANO_C_RELEASE_HAS_SHELL when sourced.
# Manual override: export NANO_C_RELEASE_HAS_SHELL=0|1 before sourcing to skip auto-detect.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
C_COM="${NANO_C_RELEASE_COM:-$ROOT/lab/nano-lisp-jit/release/nano-lisp.com}"

nanolisp_c_release_shell_probe() {
  [ -x "$C_COM" ] || {
    echo "nanolisp.c-release-shell=fail no_com path=$C_COM" >&2
    return 1
  }
  local log rc
  log=$("$C_COM" 2>&1) || rc=$?
  rc=${rc:-0}
  if echo "$log" | grep -q 'shell.mode='; then
    echo "nanolisp.c-release-shell=embedded"
    return 0
  fi
  if [ "$rc" -eq 2 ] && echo "$log" | grep -q 'usage:'; then
    echo "nanolisp.c-release-shell=gap"
    return 0
  fi
  echo "nanolisp.c-release-shell=fail rc=$rc" >&2
  echo "$log" >&2
  return 1
}

nanolisp_c_release_shell_probe_apply() {
  local line has_shell
  line=$(nanolisp_c_release_shell_probe) || return 1
  case "$line" in
    nanolisp.c-release-shell=embedded) has_shell=1 ;;
    nanolisp.c-release-shell=gap) has_shell=0 ;;
    *)
      echo "nanolisp.c-release-shell=fail unexpected=$line" >&2
      return 1
      ;;
  esac
  if [ -z "${NANO_C_RELEASE_HAS_SHELL+x}" ]; then
    export NANO_C_RELEASE_HAS_SHELL="$has_shell"
  fi
  printf '%s\n' "$line"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  nanolisp_c_release_shell_probe_apply
  exit $?
fi
