; v4.5 tier0 entry: DECISION anchor + verify-smoke corpus + kickoff regression (plan 无 .c).
(bootstrap
  (file-size "lab/nano-lisp-jit/v4.5/DECISION.md")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-smoke.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-core.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-v4-handoff.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-all.lisp")
  (file-size "lab/nano-lisp-jit/archive/c/factory/bootstrap-v4/bootstrap-v4-kickoff.lisp")
  (file-size "lab/nano-lisp-jit/archive/c/factory/bootstrap-v4/bootstrap-v4-gen5-anchor.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/bootstrap-v45-entry-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/bootstrap-v45-entry-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/bootstrap-v45-entry-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/bootstrap-v45-entry-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/control-flow.lisp"
           "lab/nano-lisp-jit/.build/bootstrap-v45-entry-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/bootstrap-v45-entry-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/bootstrap-v45-entry-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v45-entry-exit42.elf" 42)
  (file-hash "lab/nano-lisp-jit/release/nano-lisp.com"))
