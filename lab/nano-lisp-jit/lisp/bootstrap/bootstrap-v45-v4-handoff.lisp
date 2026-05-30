; v4.5 tier1: v4 → v4.5 handoff — .com runs v4 anchors + gen60 terminal slice compare (plan 无 .c).
(bootstrap
  (file-size "lab/nano-lisp-jit/v4/PROGRESS.md")
  (file-size "lab/nano-lisp-jit/archive/c/factory/bootstrap-v4/bootstrap-v4-zero-host-gen60-lispjit-from-lisp-done.lisp")
  (file-size "lab/nano-lisp-jit/archive/c/factory/bootstrap-v4/bootstrap-v4-terminal-edge.lisp")
  (file-size "lab/nano-lisp-jit/archive/c/factory/bootstrap-v4/bootstrap-v4-kickoff.lisp")
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-handoff-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-handoff-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-handoff-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-handoff-mod00.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-handoff-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-handoff-mod12.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-handoff-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-handoff-arm.elf" 7)
  (pack-app "lab/nano-lisp-jit/.build/v45-handoff-app.com"
            "lab/nano-lisp-jit/.build/v45-handoff-x86.elf"
            "lab/nano-lisp-jit/.build/v45-handoff-arm.elf"
            "lab/nano-lisp-jit/.build/v45-handoff-mod12.lbin")
  (file-hash "lab/nano-lisp-jit/.build/v45-handoff-app.com"))
