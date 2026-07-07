; v4.5 tier0: plan-only verify — mirrors run.sh VM smoke prefix (no .sh/.c/.py).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-smoke-strlen-repeat.lbin")
  (compare "lab/nano-lisp-jit/.build/v45-smoke-strlen.lbin"
           "lab/nano-lisp-jit/.build/v45-smoke-strlen-repeat.lbin")
  (run "lab/nano-lisp-jit/.build/v45-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-smoke-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic-i64.lisp"
           "lab/nano-lisp-jit/.build/v45-smoke-arithmetic-i64.lbin")
  (run "lab/nano-lisp-jit/.build/v45-smoke-arithmetic-i64.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/typed-values.lisp"
           "lab/nano-lisp-jit/.build/v45-smoke-typed.lbin")
  (run "lab/nano-lisp-jit/.build/v45-smoke-typed.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-smoke-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-smoke-ctrl.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/func-param-vm-parity.lisp"
           "lab/nano-lisp-jit/.build/v45-smoke-func-param.lbin")
  (run "lab/nano-lisp-jit/.build/v45-smoke-func-param.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/func-call-vm-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-smoke-func-call.lbin")
  (run "lab/nano-lisp-jit/.build/v45-smoke-func-call.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-smoke-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-smoke-exit42.elf" 42)
  (file-hash "lab/nano-lisp-jit/release/nano-lisp.com"))
