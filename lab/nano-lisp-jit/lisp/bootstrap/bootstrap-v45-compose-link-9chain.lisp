; Wave42 W1: plan-only compose-9link — 9 .lisp TU → compile-elf64-obj-code → link-elf64-exe (exit 42).
; Prefix v45-cl9- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl9-callee.o"
                          "nano_tu_callee")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-callee.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl9-main.o"
                          "nano_tu_main")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-main.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl9-extra.o"
                          "nano_lispjit_extra")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-extra.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl9-core.o"
                          "nano_mod_core")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-core.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl9-mf.o"
                          "nano_mf_mod")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-mf.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl9-boot.o"
                          "nano_mod_boot")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-boot.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl9-vm.o"
                          "nano_mod_vm")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-vm.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl9-aot.o"
                          "nano_mod_aot")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-aot.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl9-elf.o"
                          "nano_mod_elf")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-elf.o")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cl9-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cl9-main.o"
                  "lab/nano-lisp-jit/.build/v45-cl9-callee.o"
                  "lab/nano-lisp-jit/.build/v45-cl9-extra.o"
                  "lab/nano-lisp-jit/.build/v45-cl9-core.o"
                  "lab/nano-lisp-jit/.build/v45-cl9-mf.o"
                  "lab/nano-lisp-jit/.build/v45-cl9-boot.o"
                  "lab/nano-lisp-jit/.build/v45-cl9-vm.o"
                  "lab/nano-lisp-jit/.build/v45-cl9-aot.o"
                  "lab/nano-lisp-jit/.build/v45-cl9-elf.o")
  (file-size "lab/nano-lisp-jit/.build/v45-cl9-linked")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cl9-linked" 42)
  (file-hash "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"))
