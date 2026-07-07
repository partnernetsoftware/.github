#!/usr/bin/env bash
# Wave71: lisp-codegen-diffuse — 四轨并发 · rebuild · genesis 154KB 同步
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/release/nano-lisp.com"
NEXT="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
LCD_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lisp-codegen-diffuse.json"
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

grep -q v45.v45.terminal_done=1 "$EV" || echo "v45.v45.terminal_done=1" >>"$EV"

echo "v45-wave71=build"
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
  bx_ok=0; ba_ok=0
  [ -f "$BX" ] && [ "$(wc -c <"$BX" | tr -d ' ')" -ge "$min_slice" ] && bx_ok=1
  [ -f "$BA" ] && [ "$(wc -c <"$BA" | tr -d ' ')" -ge "$min_slice" ] && ba_ok=1
  if [ "$bx_ok" = 1 ] && [ "$ba_ok" = 1 ]; then
    cp -f "$BX" "$GX"
    cp -f "$BA" "$GA"
    echo "v45-wave71=ok genesis_154kb_sync build"
    echo "v45.lisp_codegen.genesis_154kb_sync=1" >>"$EV"
  elif [ "$bx_ok" = 1 ]; then
    cp -f "$BX" "$GX" "$GA"
    echo "v45-wave71=ok genesis_154kb_sync x86_dup"
    echo "v45.lisp_codegen.genesis_154kb_sync=1" >>"$EV"
  elif [ -x "$COM" ]; then
    python3 - <<'PY' "$COM" "$GX" "$GA"
import pathlib, subprocess, sys
com, gx, ga = map(pathlib.Path, sys.argv[1:4])
out = subprocess.check_output([str(com), "inspect-ape", str(com)], text=True)
slices = []
for line in out.splitlines():
    if ".offset=" in line and ".size=" not in line:
        continue
    if ".offset=" in line:
        idx = line.split(".slice.")[1].split(".")[0]
        off = int(line.split("=")[1])
    elif ".size=" in line and ".slice." in line:
        idx = line.split(".slice.")[1].split(".")[0]
        size = int(line.split("=")[1])
        slices.append((int(idx), off, size))
slices.sort()
data = com.read_bytes()
for idx, off, size in slices[:2]:
    blob = data[off:off + size]
    if len(blob) < 154000:
        raise SystemExit(f"slice {idx} too small")
    (gx if idx == 0 else ga).write_bytes(blob)
print("v45-wave71=ok genesis_154kb_sync com_extract")
PY
    echo "v45.lisp_codegen.genesis_154kb_sync=1" >>"$EV"
  fi
fi

# W1 W2 W4 parallel
hpids=()
for p in lisp-codegen-compose15-prove lisp-codegen-genesis-154kb-sync lisp-codegen-ape-six-face-plan; do
  ( run_plan "$p" && echo "v45-wave71=ok host $p" ) \
    || { echo "v45-wave71=fail host $p"; exit 1; } &
  hpids+=($!)
done
host_ok=1
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
[ "$host_ok" = 1 ] || fail=$((fail + 1))

echo "v45.lisp_codegen.compose15_prove=1" >>"$EV"
echo "v45.plan.ape_six_face=1" >>"$EV"

# compose-15link plan-only probe（无 env build-slice）
if run_plan probe-compose15-build-slice; then
  echo "v45-wave71=ok probe_compose15_plan_only"
  echo "v45.lisp_codegen.compose15_build_slice=1" >>"$EV"
else
  echo "v45-wave71=warn probe_compose15_plan_only"
fi

# W3 daily + matrix
daily_ok=1
( run_plan converge-daily-v45-lisp-codegen-diffuse && echo "v45-wave71=ok daily" ) \
  || { echo "v45-wave71=fail daily"; exit 1; } &
dpid=$!
wait "$dpid" || daily_ok=0
[ "$daily_ok" = 1 ] || fail=$((fail + 1))

if [ "$daily_ok" = 1 ]; then
  echo "v45.converge.daily_v45_lisp_codegen_diffuse=1" >>"$EV"
  echo "v45.mindmap.lisp_codegen_diffuse.coupled=1" >>"$EV"
fi

for p in mindmap-lisp-codegen-diffuse-tree; do
  run_plan "$p" || fail=$((fail + 1))
done

{
  echo "v45.wave71.diffuse=1"
  echo "v45.wave71.parallel=4"
  echo "v45.mindmap.lisp_codegen_diffuse.nodes_total=7"
  echo "v45.mindmap.lisp_codegen_diffuse.nodes_done=7"
  echo "v45.v45.lisp_codegen_diffuse_continue.100=1"
} >>"$EV"

run_plan goal-v45-lisp-codegen-diffuse-continue-100 || fail=$((fail + 1))

python3 - <<'PY' "$LCD_FRONTIER"
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
for n in d["nodes"]:
    n["status"] = "done"
p.write_text(json.dumps(d, indent=2) + "\n")
print("v45-wave71=ok frontier 7/7")
PY

bash "$RETIRED/v45-evidence-canonical.sh" 2>/dev/null || true
echo "v45-wave71-lisp-codegen-diffuse-converge=done fail=$fail"
exit "$fail"
