#!/usr/bin/env bash
# nanolisp run-bootstrap-plan smoke — read-file + spawn-wait + inspect-ape proc I/O.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
RS="$ROOT/lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit_rs.sh" >/dev/null
[ -x "$RS" ] || { echo "nano-jit-rs-bootstrap-proc-io-smoke=fail no_binary"; exit 1; }

mkdir -p "$(dirname "$EV")"
{
  echo "v45.goal.proc_smoke=1"
  echo "v45.goal.proc_io=1"
} >"$EV"

PLAN=$(mktemp --suffix=.lisp)
cat >"$PLAN" <<EOF
(bootstrap
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (spawn-wait 0 "/bin/true")
  (spawn-wait 7 "/bin/sh" "-c" "exit 7")
  (inspect-ape "lab/nano-lisp-jit/release/nanolisp.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_io" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.proc_smoke" "1"))
EOF

log=$("$RS" run-bootstrap-plan "$PLAN" 2>&1) || true
rm -f "$PLAN"

echo "$log" | grep -q 'bootstrap-plan.ok=1' || {
  echo "nano-jit-rs-bootstrap-proc-io-smoke=fail plan"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'read-file.ok=1' || {
  echo "nano-jit-rs-bootstrap-proc-io-smoke=fail read_file"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'spawn-wait.ok=1' || {
  echo "nano-jit-rs-bootstrap-proc-io-smoke=fail spawn"
  echo "$log"
  exit 1
}
echo "$log" | grep -q 'inspect-ape.ok=1' || {
  echo "nano-jit-rs-bootstrap-proc-io-smoke=fail inspect"
  echo "$log"
  exit 1
}

echo "nano-jit-rs-bootstrap-proc-io-smoke=ok"
