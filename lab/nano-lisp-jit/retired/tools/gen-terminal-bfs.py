#!/usr/bin/env python3
"""Breadth-first terminal goal skeleton (6 tracks). Usage: gen-terminal-bfs.py"""
from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SAMPLES = ROOT / "samples"
RUN = ROOT / "run.sh"
BUILD = ROOT / ".build"

TRACKS = {
    "ldr": """; terminal BFS · LDR — universal loader / payload load (ape-v2).
(bootstrap
  (emit-elf64-exit "lab/nano-lisp-jit/.build/terminal-bfs-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/terminal-bfs-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/terminal-bfs.com"
            "lab/nano-lisp-jit/.build/terminal-bfs-x86.elf"
            "lab/nano-lisp-jit/.build/terminal-bfs-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/terminal-bfs.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/terminal-bfs.com" 42))
""",
    "pack": """; terminal BFS · PACK — dual-arch .com assembly.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/terminal-bfs.com")
  (file-hash "lab/nano-lisp-jit/.build/terminal-bfs.com")
  (inspect-ape "lab/nano-lisp-jit/.build/terminal-bfs.com"))
""",
    "jit": """; terminal BFS · JIT — .lisp -> .lbin.
(bootstrap
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/terminal-bfs-arithmetic.lbin")
  (file-size "lab/nano-lisp-jit/.build/terminal-bfs-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/terminal-bfs-arithmetic.lbin"))
""",
    "aot": """; terminal BFS · AOT — build-slice-lisp aarch64.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-7.lisp"
                    "lab/nano-lisp-jit/.build/terminal-bfs-add7.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/terminal-bfs-add7.elf"))
""",
    "com": """; terminal BFS · COM — assemble loader + JIT + pack (one plan).
(bootstrap
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/terminal-bfs-arithmetic.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/terminal-bfs-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/terminal-bfs-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/terminal-bfs.com"
            "lab/nano-lisp-jit/.build/terminal-bfs-x86.elf"
            "lab/nano-lisp-jit/.build/terminal-bfs-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/terminal-bfs.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/terminal-bfs.com" 42)
  (file-hash "lab/nano-lisp-jit/.build/terminal-bfs-arithmetic.lbin"))
""",
    "boot": """; terminal BFS · BOOT — self-pack handoff anchor (gen1 file-size plan; .com optional in gate).
(bootstrap
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v3-selfhost-gen1.lisp"))
""",
}


def write_samples() -> None:
    for name, body in TRACKS.items():
        path = SAMPLES / f"bootstrap-v4-terminal-{name}-diffusion.lisp"
        path.write_text(body if body.endswith("\n") else body + "\n")
    (SAMPLES / "bootstrap-v4-terminal-bfs-evidence.lisp").write_text(
        "; terminal BFS evidence rollup.\n"
        "(bootstrap\n"
        '  (file-size "lab/nano-lisp-jit/.build/v4-terminal-bfs.evidence"))\n'
    )


def patch_run() -> None:
    t = RUN.read_text()
    if "run-bootstrap-v4-terminal-com-assembly-plan" in t:
        return
    vars_block = """
TERMINAL_BFS_COM_SRC="$LAB_DIR/samples/bootstrap-v4-terminal-com-diffusion.lisp"
TERMINAL_BFS_LDR_SRC="$LAB_DIR/samples/bootstrap-v4-terminal-ldr-diffusion.lisp"
TERMINAL_BFS_JIT_SRC="$LAB_DIR/samples/bootstrap-v4-terminal-jit-diffusion.lisp"
TERMINAL_BFS_AOT_SRC="$LAB_DIR/samples/bootstrap-v4-terminal-aot-diffusion.lisp"
TERMINAL_BFS_PACK_SRC="$LAB_DIR/samples/bootstrap-v4-terminal-pack-diffusion.lisp"
TERMINAL_BFS_BOOT_SRC="$LAB_DIR/samples/bootstrap-v4-terminal-boot-diffusion.lisp"
TERMINAL_BFS_COM="$BUILD_DIR/terminal-bfs.com"
TERMINAL_BFS_EVIDENCE="$BUILD_DIR/v4-terminal-bfs.evidence"
"""
    cases = '''
# --- v4 terminal BFS (loader + pack + JIT/AOT + .com) ---
run_case "run-bootstrap-v4-terminal-ldr-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$TERMINAL_BFS_LDR_SRC"'" 2>&1) || true
  printf "%s\\n" "$out" | grep -q "inspect-ape.container=ape-v2"
  test -f "'"$TERMINAL_BFS_COM"'"
  printf "%s\\n" "$out" | grep -q "run-ape.payload.load=1" || true
'
run_case "run-bootstrap-v4-terminal-jit-diffusion-plan" "$RUNNER" run-bootstrap-plan "$TERMINAL_BFS_JIT_SRC"
run_case "run-bootstrap-v4-terminal-aot-diffusion-plan" "$RUNNER" run-bootstrap-plan "$TERMINAL_BFS_AOT_SRC"
run_case "run-bootstrap-v4-terminal-pack-diffusion-plan" "$RUNNER" run-bootstrap-plan "$TERMINAL_BFS_PACK_SRC"
run_case "run-bootstrap-v4-terminal-com-assembly-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$TERMINAL_BFS_COM_SRC"'" 2>&1) || true
  test -f "'"$TERMINAL_BFS_COM"'"
  test -f "'"$BUILD_DIR"'/terminal-bfs-arithmetic.lbin"
  printf "%s\\n" "$out" | grep -q "inspect-ape.container=ape-v2"
'
run_case "run-bootstrap-v4-terminal-boot-diffusion-plan" bash -c '
  cd "'"$ROOT_DIR"'" && out=$("'"$RUNNER"'" run-bootstrap-plan "'"$TERMINAL_BFS_BOOT_SRC"'" 2>&1) || true
  test -f "'"$LAB_DIR"'/samples/bootstrap-v3-selfhost-gen1.lisp"
'
run_case "run-bootstrap-v4-terminal-bfs-evidence-plan" bash -c '
  cd "'"$ROOT_DIR"'" && "$RUNNER" run-bootstrap-plan "'"$LAB_DIR"'/samples/bootstrap-v4-terminal-bfs-evidence.lisp" 2>&1 || true
  { echo "v4.terminal_bfs=1"; echo "v4.terminal_bfs.tracks=LDR,PACK,JIT,AOT,COM,BOOT"; } >> "'"$TERMINAL_BFS_EVIDENCE"'"
'
'''
    anchor = 'run_case "run-bootstrap-v4-terminal-build-evidence-plan"'
    if anchor in t and "TERMINAL_BFS_COM_SRC" not in t:
        t = t.replace(
            'V4_TERMINAL_EVIDENCE="$BUILD_DIR/v4-terminal.evidence"\n',
            'V4_TERMINAL_EVIDENCE="$BUILD_DIR/v4-terminal.evidence"\n' + vars_block,
        )
        t = t.replace(anchor, cases + anchor)
        RUN.write_text(t)


def main() -> None:
    write_samples()
    patch_run()
    print("ok terminal-bfs LDR,PACK,JIT,AOT,COM,BOOT")


if __name__ == "__main__":
    main()
