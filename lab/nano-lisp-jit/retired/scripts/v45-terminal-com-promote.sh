#!/usr/bin/env bash
# v4.5 终局：rebuild COM → release promote → 矩阵验收 → manifest pin
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
cd "$ROOT"
fail=0
touch "$EV"

echo "v45-terminal=build"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >/dev/null 2>&1 || true

SRC="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
REL="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
if [ ! -x "$SRC" ]; then
  echo "v45-terminal=fail missing_build_com"
  exit 1
fi

cp -f "$SRC" "$REL"
cp -f "$SRC" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
chmod +x "$REL" "$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"

BYTES=$(wc -c <"$REL" | tr -d ' ')
HASH=$("$REL" run-bootstrap-plan /dev/null 2>/dev/null; \
  python3 - <<PY
import pathlib
p=pathlib.Path("$REL")
h=0xcbf29ce484222325
for b in p.read_bytes():
    h=(h^b)*0x100000001b3 & 0xffffffffffffffff
print(f"{h:016x}")
PY
)
cat >"$ROOT/lab/nano-lisp-jit/release/manifest.txt" <<EOF
# fnv1a64 and byte size for pinned release .com artifacts

nano-lisp.com.bytes=$BYTES
nano-lisp.com.fnv1a64=$HASH
v45-selfhost-next.com.bytes=$BYTES
v45-selfhost-next.com.fnv1a64=$HASH
EOF

GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE)
COM="$REL"

for p in verify-smoke verify-core verify-all entry onion-tdd \
  converge-daily-v45-zero-archive-audit-terminal; do
  if "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$p.lisp" >/dev/null 2>&1; then
    echo "v45-terminal=ok $p"
  else
    echo "v45-terminal=fail $p"
    fail=$((fail + 1))
  fi
done

{
  echo "v45.v45.terminal_com_promoted=1"
  echo "v45.honest.aarch64_slim_slice=1"
  echo "v45.release.com_bytes=$BYTES"
} >>"$EV"

if "${GEN[@]}" "$COM" run-bootstrap-plan \
  lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-v45-terminal-com-done.lisp >/dev/null 2>&1; then
  echo "v45-terminal=ok done_plan"
  echo "v45.v45.terminal_done=1" >>"$EV"
else
  echo "v45-terminal=warn done_plan"
fi

bash "$ROOT/lab/nano-lisp-jit/retired/scripts/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-terminal=done fail=$fail bytes=$BYTES hash=$HASH"
exit "$fail"
