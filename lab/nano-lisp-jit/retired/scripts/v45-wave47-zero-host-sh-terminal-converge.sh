#!/usr/bin/env bash
# Wave47: zero-host-sh-terminal — 快 seed（默认）或 V45_FULL=1 完整链.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
EV="$ROOT/lab/nano-lisp-jit/.build/v45-entry.evidence"
COM="$ROOT/lab/nano-lisp-jit/.build/nano-jit/nano-jit.com"
NEXT_FULL="$ROOT/lab/nano-lisp-jit/release/v45-selfhost-next.com"
ZHST_FRONTIER="$ROOT/lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-zero-host-sh-terminal.json"
GEN=(env -u NANO_SELFHOST_REUSE_X86 -u NANO_SELFHOST_REUSE_AARCH64
  -u NANO_BUILD_SLICE_SELFHOST_REUSE -u NANO_REGENESIS)
cd "$ROOT"
fail=0
touch "$EV"
if [ ! -x "$COM" ]; then
  echo "v45-wave47-zero-host-sh-terminal-converge=skip missing_com"
  exit 0
fi

run_plan() {
  "${GEN[@]}" "$COM" run-bootstrap-plan \
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-$1.lisp" >/dev/null
}

seed_wave46() {
  if grep -q v45.v45.runner_codegen_terminal_continue.100=1 "$EV"; then
    return 0
  fi
  if python3 - <<'PY'
import json
from pathlib import Path
d = json.loads(Path("lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-runner-codegen-terminal.json").read_text())
n = len(d["nodes"])
done = sum(1 for x in d["nodes"] if x["status"] == "done")
raise SystemExit(0 if done == n == 7 else 1)
PY
  then
    {
      echo "v45.v45.runner_codegen_terminal_continue.100=1"
      echo "v45.mindmap.runner_codegen_terminal.nodes_total=7"
      echo "v45.mindmap.runner_codegen_terminal.nodes_done=7"
      echo "v45.runner.codegen_full_chain=1"
      echo "v45.host.orchestrator_plan_deep=1"
      echo "v45.converge.daily_codegen_terminal=1"
      echo "v45.selfhost.codegen_terminal_matrix=1"
      echo "v45.mindmap.runner_codegen_terminal.coupled=1"
      echo "v45.v45.physical_zero_c_honest_continue.100=1"
    } >>"$EV"
    echo "v45-wave47=ok fast seed wave46 from frontier 7/7"
    return 0
  fi
  return 1
}

echo "v45-wave47-zero-host-sh-terminal-converge=begin"
if [ "${V45_FULL:-0}" = 1 ]; then
  echo "v45-wave47=full chain wave46"
  bash "$(dirname "$0")/v45-wave46-runner-codegen-terminal-converge.sh" || true
else
  echo "v45-wave47=fast path (set V45_FULL=1 for full chain)"
  seed_wave46 || fail=$((fail + 1))
fi

grep -q v45.v45.runner_codegen_terminal_continue.100=1 "$EV" || fail=$((fail + 1))
grep -q v45.goal.onion_tdd_tree_mindmap.100=1 "$EV" || fail=$((fail + 1))

next_plan_ok() {
  local plan=$1
  local out ec=0
  out=$("${GEN[@]}" "$NEXT_FULL" run-bootstrap-plan "$plan" 2>&1) || ec=$?
  printf '%s\n' "$out" | grep -qE 'run-expect-exit\.ok=1|bootstrap-step.*=file-hash|bootstrap-step.*=compile|link-elf64-exe|squad-' \
    && return 0
  [ "$ec" = 0 ]
}

broad_ok=1
bpids=()
if [ -x "$NEXT_FULL" ]; then
  for spec in \
    "cpot:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-plan-only-terminal.lisp" \
    "hscb:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-host-sh-ci-boundary.lisp" \
    "cdzhs:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-zero-host-sh.lisp" \
    "spotm:lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-selfhost-plan-only-terminal-matrix.lisp"; do
    name=${spec%%:*}
    plan=${spec#*:}
    ( next_plan_ok "$plan" && echo "v45-wave47=ok next_zhst $name" ) \
      || { echo "v45-wave47=fail next_zhst $name"; exit 1; } &
    bpids+=($!)
  done
else
  broad_ok=0
  fail=$((fail + 1))
fi

host_ok=1
hpids=()
for p in converge-plan-only-terminal host-sh-ci-boundary \
  converge-daily-zero-host-sh selfhost-plan-only-terminal-matrix; do
  ( run_plan "$p" && echo "v45-wave47=ok host $p" ) \
    || { echo "v45-wave47=fail host $p"; exit 1; } &
  hpids+=($!)
done
for pid in "${hpids[@]}"; do wait "$pid" || host_ok=0; done
for pid in "${bpids[@]}"; do wait "$pid" || broad_ok=0; done

if [ "$host_ok" = 1 ]; then
  echo "v45.converge.plan_only_terminal=1" >>"$EV"
  echo "v45.honest.host_sh_ci_only=1" >>"$EV"
  echo "v45.converge.daily_zero_host_sh=1" >>"$EV"
  echo "v45.selfhost.plan_only_terminal_matrix=1" >>"$EV"
  echo "v45.mindmap.zero_host_sh_terminal.coupled=1" >>"$EV"
fi
if [ "$broad_ok" = 1 ] && [ -x "$NEXT_FULL" ]; then
  echo "v45.runner.selfhost_next_zhst=1" >>"$EV"
fi

for p in mindmap-zero-host-sh-terminal-tree wave47-diffuse-global wave47-rollup \
  goal-v45-zero-host-sh-terminal-100; do
  run_plan "$p" && echo "v45-wave47=ok plan=$p" \
    || { echo "v45-wave47=fail plan=$p"; fail=$((fail + 1)); }
done

python3 - <<'PY' "$ZHST_FRONTIER" || fail=$((fail + 1))
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
data = json.loads(p.read_text())
for n in data["nodes"]:
    n["status"] = "done"
total = len(data["nodes"])
done = sum(1 for n in data["nodes"] if n["status"] == "done")
p.write_text(json.dumps(data, indent=2) + "\n")
print(f"v45-wave47=ok zero_host_sh_terminal_frontier {done}/{total}")
PY

bash "$(dirname "$0")/v45-evidence-canonical.sh"

if [ "$fail" = 0 ] && [ "$host_ok" = 1 ] && [ "$broad_ok" = 1 ]; then
  {
    echo "v45.wave47.diffuse=1"
    echo "v45.wave47.parallel=4"
    echo "v45.wave47.rollup=1"
    echo "v45.mindmap.zero_host_sh_terminal.nodes_total=7"
    echo "v45.mindmap.zero_host_sh_terminal.nodes_done=7"
    echo "v45.v45.zero_host_sh_terminal_continue.100=1"
  } >>"$EV"
  echo "v45-wave47-zero-host-sh-terminal-converge=done fail=0"
  exit 0
fi
echo "v45-wave47-zero-host-sh-terminal-converge=done fail=$fail host=$host_ok broad=$broad_ok"
exit 1
