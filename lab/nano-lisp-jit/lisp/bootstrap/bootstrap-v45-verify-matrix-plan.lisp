; Wave37 W3: verify 矩阵迁入 plan — smoke + core 子集（无 .sh/.c/.py）.
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-vmp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-vmp-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-vmp-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-vmp-smoke-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-vmp-smoke-ctrl.lbin")
  (run "lab/nano-lisp-jit/.build/v45-vmp-smoke-ctrl.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-vmp-smoke-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-vmp-smoke-exit42.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/core/ptr-values.lisp"
           "lab/nano-lisp-jit/.build/v45-vmp-core-ptr.lbin")
  (run "lab/nano-lisp-jit/.build/v45-vmp-core-ptr.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
           "lab/nano-lisp-jit/.build/v45-vmp-core-multi.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                     "lab/nano-lisp-jit/.build/v45-vmp-core-multi.elf"
                     "nano_v45_multi")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-vmp-core-multi.elf" 43)
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-smoke.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-core.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-verify-matrix-plan.lisp"))
