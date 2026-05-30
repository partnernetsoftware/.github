; probe: plan-only compose-15link（无 env build-slice lispjit.c）.
(bootstrap
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-probe-c15-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-probe-c15-callee.o"
                          "nano_tu_callee")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-probe-c15-x86.elf"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-probe-c15-main.o"
                  "lab/nano-lisp-jit/.build/v45-probe-c15-callee.o")
  (file-size "lab/nano-lisp-jit/.build/v45-probe-c15-x86.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-probe-c15-x86.elf" 42))
