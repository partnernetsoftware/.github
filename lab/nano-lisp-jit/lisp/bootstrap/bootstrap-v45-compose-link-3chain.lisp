; Wave41 W2: plan-only compose-3link — 3 .lisp TU → compile-elf64-obj-code → link-elf64-exe (exit 42).
; Prefix v45-cl3- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl3-callee.o"
                          "nano_tu_callee")
  (file-size "lab/nano-lisp-jit/.build/v45-cl3-callee.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl3-main.o"
                          "nano_tu_main")
  (file-size "lab/nano-lisp-jit/.build/v45-cl3-main.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl3-extra.o"
                          "nano_lispjit_extra")
  (file-size "lab/nano-lisp-jit/.build/v45-cl3-extra.o")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cl3-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cl3-main.o"
                  "lab/nano-lisp-jit/.build/v45-cl3-callee.o"
                  "lab/nano-lisp-jit/.build/v45-cl3-extra.o")
  (file-size "lab/nano-lisp-jit/.build/v45-cl3-linked")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cl3-linked" 42)
  (file-hash "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"))
