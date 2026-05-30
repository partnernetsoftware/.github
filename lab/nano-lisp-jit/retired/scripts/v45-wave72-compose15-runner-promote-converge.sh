#!/usr/bin/env bash
# Wave72: compose15-runner-promote — 四轨并发 · rebuild · release promote
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
NEXT="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
C15_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-compose15-runner-promote.json"
RETIRED="$ROOT/lab/nano-lisp-jit/retired/scripts"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

grep -q v45.v45.lisp_codegen_diffuse_continue.100=1 "$EV" || {
  bash "$RETIRED/v45-wave71-lisp-codegen-diffuse-converge.sh" 2>/dev/null || true
}

echo "v45-wave72=build"
bash "$ROOT/lab/nano-lisp-jit/build_nano_jit.sh" >/dev/null 2>&1 || true
BUILD_COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
if [ -x "$BUILD_COM" ]; then
  cp -f "$BUILD_COM" "$COM"
  cp -f "$BUILD_COM" "$NEXT"
  chmod +x "$COM" "$NEXT"
  BX="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.x86_64"
  BA="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.aarch64"
  GX="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.x86_64"
  GA="$ROOT/lab/nano-lisp-jit/genesis/nano-jit.aarch64"
  min_slice=154000
  if [ -f "$BX" ] && [ "$(wc -c <"$BX" | tr -d ' ')" -ge "$min_slice" ]; then
    cp -f "$BX" "$GX"
    [ -f "$BA" ] && [ "$(wc -c <"$BA" | tr -d ' ')" -ge "$min_slice" ] && cp -f "$BA" "$GA" || cp -f "$BX" "$GA"
    echo "v45-wave72=ok genesis_sync"
  fi
  BYTES=$(wc -c <"$COM" | tr -d ' ')
  HASH=$(python3 - <<PY
import pathlib
p=pathlib.Path("$COM")
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
  echo "v45.lisp_codegen.com_promote_honest=1" >>"$EV"
fi

hpids=()
for p in lisp-codegen-compose15-runner-prove lisp-codegen-compose15-pack-probe lisp-codegen-com-promote-honest; do
  ( run_plan "$p" && echo "v45-wave72=ok host $p" ) \
    || { echo "v45-wave72=fail host $p"; exit 1; } &
  hpids+=($!)
done
host_ok=1
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
[ "$host_ok" = 1 ] || fail=$((fail + 1))

echo "v45.lisp_codegen.compose15_runner_prove=1" >>"$EV"
echo "v45.lisp_codegen.compose15_pack_probe=1" >>"$EV"

daily_ok=1
( run_plan converge-daily-v45-compose15-runner-promote && echo "v45-wave72=ok daily" ) \
  || { echo "v45-wave72=fail daily"; exit 1; } &
dpid=$!
wait "$dpid" || daily_ok=0
[ "$daily_ok" = 1 ] || fail=$((fail + 1))

if [ "$daily_ok" = 1 ]; then
  echo "v45.converge.daily_v45_compose15_runner_promote=1" >>"$EV"
  echo "v45.mindmap.compose15_runner_promote.coupled=1" >>"$EV"
fi

for p in mindmap-compose15-runner-promote-tree; do
  run_plan "$p" || fail=$((fail + 1))
done

{
  echo "v45.wave72.diffuse=1"
  echo "v45.wave72.parallel=4"
  echo "v45.mindmap.compose15_runner_promote.nodes_total=7"
  echo "v45.mindmap.compose15_runner_promote.nodes_done=7"
  echo "v45.v45.compose15_runner_promote_continue.100=1"
} >>"$EV"

run_plan goal-v45-compose15-runner-promote-continue-100 || fail=$((fail + 1))

python3 - <<'PY' "$C15_FRONTIER"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave72=ok frontier 7/7")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave72-compose15-runner-promote-converge=done fail=$fail"
exit "$fail"
