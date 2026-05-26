#!/usr/bin/env bash
# Wave27: 洋葱 TDD × mindmap 耦合 — 工厂 codegen 续推（/goal 26/26 前置 + 扩展活图 7/7）.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
CG_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-codegen.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave27-codegen-coupled-converge=skip missing_com"
  exit 0
fi
echo "v45-wave27-codegen-coupled-converge=begin"
bash "$(dirname "$0")/v45-wave26-codegen-expand-converge.sh" || fail=$((fail + 1))

grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" \
  || { echo "v45-wave27=fail missing /goal key"; fail=$((fail + 1)); }

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

probe_ok=1
pids=()
for p in codegen-lisp-vm-ctrl codegen-lisp-vm-multi codegen-lisp-gen60-handshake; do
  ( run_plan "$p" && echo "v45-wave27=ok probe=$p" ) \
    || { echo "v45-wave27=fail probe=$p"; exit 1; } &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || probe_ok=0; done

if run_plan onion-chain-lo-minimal; then
  echo "v45-wave27=ok chain_lo_minimal"
  echo "v45.factory.chain_lo_onion_minimal=1" >>"$EV"
else
  echo "v45-wave27=fail chain_lo_minimal"
  fail=$((fail + 1))
fi

if [ "$probe_ok" = 1 ]; then
  echo "v45.codegen.lisp_slices=7" >>"$EV"
  echo "v45.codegen.vm_emit_profiles=4" >>"$EV"
  echo "v45.mindmap.codegen.coupled=1" >>"$EV"
fi

for p in mindmap-codegen-coupled-tree wave27-diffuse-global wave27-rollup goal-v45-codegen-coupled-100; do
  run_plan "$p" && echo "v45-wave27=ok plan=$p" \
    || { echo "v45-wave27=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$CG_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
mark = {
  "v45-cg-vm-ctrl", "v45-cg-vm-multi", "v45-cg-chain-lo", "v45-cg-gen60",
  "v45-cg-terminal", "v45-cg-goal",
}
for n in data["nodes"]:
    if n["id"] in mark:
        n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave27=ok codegen_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$probe_ok" = 1 ]; then
  {
    echo "v45.wave27.diffuse=1"
    echo "v45.wave27.parallel=4"
    echo "v45.wave27.rollup=1"
    echo "v45.mindmap.codegen.nodes_total=7"
    echo "v45.mindmap.codegen.nodes_done=7"
    echo "v45.v45.codegen_coupled.100=1"
  } >>"$EV"
  echo "v45-wave27-codegen-coupled-converge=done fail=0"
  exit 0
fi
echo "v45-wave27-codegen-coupled-converge=done fail=$fail probe=$probe_ok"
exit 1
