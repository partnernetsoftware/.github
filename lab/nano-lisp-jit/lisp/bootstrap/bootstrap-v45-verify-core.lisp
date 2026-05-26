; v4.5 tier1: plan-only core verify — VM + ptr + multi-func + APE/pack-app (no .sh/.c/.py).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
           "lab/nano-lisp-jit/.build/v45-core-multi.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                     "lab/nano-lisp-jit/.build/v45-core-multi.elf"
                     "nano_v45_multi")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-core-multi.elf" 43)
  (compile "lab/nano-lisp-jit/lisp/core/multi-func-control-flow.lisp"
           "lab/nano-lisp-jit/.build/v45-core-multi-ctrl.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/lisp/core/multi-func-control-flow.lisp"
                     "lab/nano-lisp-jit/.build/v45-core-multi-ctrl.elf"
                     "nano_v45_multi_ctrl")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-core-multi-ctrl.elf" 43)
  (compile "lab/nano-lisp-jit/lisp/core/ptr-values.lisp"
           "lab/nano-lisp-jit/.build/v45-core-ptr.lbin")
  (run "lab/nano-lisp-jit/.build/v45-core-ptr.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/const-ptr-load-u8.lisp"
           "lab/nano-lisp-jit/.build/v45-core-const-ptr.lbin")
  (run "lab/nano-lisp-jit/.build/v45-core-const-ptr.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/rodata-readonly.lisp"
           "lab/nano-lisp-jit/.build/v45-core-rodata.lbin")
  (run "lab/nano-lisp-jit/.build/v45-core-rodata.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/func-param-vm-i64.lisp"
           "lab/nano-lisp-jit/.build/v45-core-func-i64.lbin")
  (run "lab/nano-lisp-jit/.build/v45-core-func-i64.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/libc-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-core-libc.lbin")
  (resolve-quiet "lab/nano-lisp-jit/.build/v45-core-libc.lbin")
  (run "lab/nano-lisp-jit/.build/v45-core-libc.lbin")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-core-aot-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-core-aot-exit42.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-core-arithmetic.lbin")
  (aot-elf64-exit "lab/nano-lisp-jit/.build/v45-core-arithmetic.lbin"
                  "lab/nano-lisp-jit/.build/v45-core-arithmetic-exit.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-core-arithmetic-exit.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-core-ape-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-core-ape-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/v45-core-ape.com"
            "lab/nano-lisp-jit/.build/v45-core-ape-x86.elf"
            "lab/nano-lisp-jit/.build/v45-core-ape-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-core-ape.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-core-ape.com" 42)
  (pack-app "lab/nano-lisp-jit/.build/v45-core-app.com"
            "lab/nano-lisp-jit/.build/v45-core-ape-x86.elf"
            "lab/nano-lisp-jit/.build/v45-core-ape-arm.elf"
            "lab/nano-lisp-jit/.build/v45-core-arithmetic.lbin")
  (inspect-app "lab/nano-lisp-jit/.build/v45-core-app.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-core-app.com"))
