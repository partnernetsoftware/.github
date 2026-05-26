; Wave45 W1: 154KB runner codegen 深探 — 15link + 13 模块 + ir-table broad.
; Prefix v45-rlcd- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-rlcd-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rlcd-mod04.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
           "lab/nano-lisp-jit/.build/v45-rlcd-mod05.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rlcd-mod05.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
           "lab/nano-lisp-jit/.build/v45-rlcd-mod06.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rlcd-mod06.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-extra.o"
                          "nano_lispjit_extra")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-mf.o"
                          "nano_mf_mod")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-boot.o"
                          "nano_mod_boot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-vm.o"
                          "nano_mod_vm")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-aot.o"
                          "nano_mod_aot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-elf.o"
                          "nano_mod_elf")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-rlcd-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-rlcd-main.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-callee.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-extra.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-core.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-mf.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-boot.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-vm.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-aot.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-elf.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rlcd-linked" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-rlcd-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rlcd-min-x86.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.modules_full_13" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.runner_codegen_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp"))
