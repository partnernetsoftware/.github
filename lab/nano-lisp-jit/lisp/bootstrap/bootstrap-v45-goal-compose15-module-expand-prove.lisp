; Wave80 W3: plan-only expand 15link — modules-expand 全链.
(bootstrap
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main-expand.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15me80-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-callee-expand.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15me80-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules-expand/00-runtime-core-expand.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15me80-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules-expand/04-vm-expand.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15me80-vm.o"
                          "nano_mod_vm")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func-control-flow.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15me80-mf.o"
                          "nano_mf_mod")
  (file-size "lab/nano-lisp-jit/.build/v45-c15me80-main.o")
  (file-size "lab/nano-lisp-jit/.build/v45-c15me80-vm.o")
  (file-size "lab/nano-lisp-jit/.build/v45-c15me80-mf.o")
  (file-hash "lab/nano-lisp-jit/lisp/modules-expand/04-vm-expand.lisp"))
