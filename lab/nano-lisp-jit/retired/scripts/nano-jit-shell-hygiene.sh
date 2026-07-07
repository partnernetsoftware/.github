#!/usr/bin/env bash
# Wave 7 post-closure hygiene — stale SSOT grep + shell ladder proof (no full dual-gate).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
SCRIPTS="$ROOT/lab/nano-lisp-jit/retired/scripts"
MANIFEST="$ROOT/lab/nano-lisp-jit/release/manifest.txt"
cd "$ROOT"

echo "nano-jit-shell-hygiene=begin"

# 1) manifest vs release README (legacy 334537 is stale after Wave 6 pin)
expected_bytes=$(grep -E '^nano-lisp\.com\.bytes=' "$MANIFEST" | cut -d= -f2)
if [ -z "$expected_bytes" ]; then
  echo "nano-jit-shell-hygiene=fail manifest missing nano-lisp.com.bytes"
  exit 1
fi
if grep -q '334.537\|334537' "$ROOT/lab/nano-lisp-jit/release/README.md" 2>/dev/null; then
  echo "nano-jit-shell-hygiene=fail stale release/README.md bytes=334537 expected=$expected_bytes"
  exit 1
fi
actual_bytes=$(wc -c <"$ROOT/lab/nano-lisp-jit/release/nano-lisp.com" | tr -d ' ')
if [ "$actual_bytes" != "$expected_bytes" ]; then
  echo "nano-jit-shell-hygiene=fail com bytes=$actual_bytes manifest=$expected_bytes"
  exit 1
fi
echo "nano-jit-shell-hygiene=ok manifest bytes=$expected_bytes"

# 2) release + product tracks must not advertise legacy pin as current SSOT
for f in "$ROOT/lab/nano-lisp-jit/release/README.md" "$ROOT/lab/nano-lisp-jit/v4.5/PRODUCT-TRACKS.md"; do
  if [ -f "$f" ] && grep -qE '334.?537|334537' "$f"; then
    echo "nano-jit-shell-hygiene=fail stale pin in $f"
    exit 1
  fi
done
echo "nano-jit-shell-hygiene=ok release_docs"

# 3) ladder proof (subset — same as closure meta smoke)
bash "$SCRIPTS/nano-jit-shell-ladder-smoke.sh"

echo "nano-jit-shell-hygiene=ok"
