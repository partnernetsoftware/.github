; Wave41 W3: plan-only compose-5link probe — 3chain + 00-runtime-core + multi-func TU → link-elf64-exe (exit 42).
; Prefix v45-cl5- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl5-callee.o"
                          "nano_tu_callee")
  (file-size "lab/nano-lisp-jit/.build/v45-cl5-callee.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl5-main.o"
                          "nano_tu_main")
  (file-size "lab/nano-lisp-jit/.build/v45-cl5-main.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl5-extra.o"
                          "nano_lispjit_extra")
  (file-size "lab/nano-lisp-jit/.build/v45-cl5-extra.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl5-core.o"
                          "nano_mod_core")
  (file-size "lab/nano-lisp-jit/.build/v45-cl5-core.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl5-mf.o"
                          "nano_mf_mod")
  (file-size "lab/nano-lisp-jit/.build/v45-cl5-mf.o")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cl5-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cl5-main.o"
                  "lab/nano-lisp-jit/.build/v45-cl5-callee.o"
                  "lab/nano-lisp-jit/.build/v45-cl5-extra.o"
                  "lab/nano-lisp-jit/.build/v45-cl5-core.o"
                  "lab/nano-lisp-jit/.build/v45-cl5-mf.o")
  (file-size "lab/nano-lisp-jit/.build/v45-cl5-linked")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cl5-linked" 42)
  (compile-elf64-exe "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                     "lab/nano-lisp-jit/.build/v45-cl5-multi.elf"
                     "nano_v45_multi")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cl5-multi.elf" 43)
  (compile "lab/nano-lisp-jit/lisp/modules/02-compile.lisp"
           "lab/nano-lisp-jit/.build/v45-cl5-mod02.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cl5-mod02.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-cl5-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cl5-mod04.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp"))
