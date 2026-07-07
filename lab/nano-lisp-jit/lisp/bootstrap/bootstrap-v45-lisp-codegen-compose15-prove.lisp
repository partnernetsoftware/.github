; Wave71 W1: compose-15 plan-only prove + build-slice compose-15link 探针.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-15chain.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-lc15-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-lc15-callee.o"
                          "nano_tu_callee")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-lc15-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-lc15-main.o"
                  "lab/nano-lisp-jit/.build/v45-lc15-callee.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-lc15-linked" 42)
  (file-size "lab/nano-lisp-jit/.build/v45-lc15-linked")
  (file-hash "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"))
