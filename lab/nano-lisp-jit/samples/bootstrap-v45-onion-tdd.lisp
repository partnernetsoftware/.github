; v4.5 onion TDD master: acceptance via .com + *.lisp only (no run.sh steps in plan).
(bootstrap
  (file-size "lab/nano-lisp-jit/v4.5/ONION-TDD.md")
  (file-size "lab/nano-lisp-jit/v4.5/DECISION.md")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v45-verify-smoke.lisp")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v45-verify-core.lisp")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v45-v4-handoff.lisp")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v45-build-slice-genesis.lisp")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v45-boundary-probe.lisp")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v45-boundary-negative.lisp")
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-onion-slice-x86.elf"
               "x86_64")
  (compare "lab/nano-lisp-jit/.build/v45-onion-slice-x86.elf"
           "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-onion-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-onion-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/samples/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-onion-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-onion-strlen.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-onion-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-onion-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/v45-onion-ape.com"
            "lab/nano-lisp-jit/.build/v45-onion-x86.elf"
            "lab/nano-lisp-jit/.build/v45-onion-arm.elf")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-onion-ape.com" 42)
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64"))
