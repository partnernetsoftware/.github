# Genesis shrink build-log audit — sourced by run.sh and build_nano_jit.sh.
# Fails when a daily build log shows host cc on a lispjit.c build-slice.

audit_genesis_shrink_log() {
  local log_file="${1:?log file required}"

  if [ "${NANO_REGENESIS:-}" = "1" ]; then
    printf 'genesis-shrink.audit=skip reason=NANO_REGENESIS\n'
    return 0
  fi
  if [ ! -f "$log_file" ]; then
    printf 'genesis-shrink.audit=fail reason=missing_log path=%s\n' "$log_file" >&2
    return 1
  fi

  if awk '
    /^build-slice\.compiler=cc$/ { pending_cc=1; next }
    /^build-slice\.source=/ {
      if (pending_cc && $0 ~ /lispjit\.c/) exit 1
      pending_cc=0
      next
    }
    /^build-slice\.compiler=/ { pending_cc=0 }
  ' "$log_file"; then
    printf 'genesis-shrink.audit=ok log=%s\n' "$log_file"
    return 0
  fi

  printf 'genesis-shrink.audit=fail reason=host_cc_on_lispjit.c log=%s\n' "$log_file" >&2
  return 1
}
