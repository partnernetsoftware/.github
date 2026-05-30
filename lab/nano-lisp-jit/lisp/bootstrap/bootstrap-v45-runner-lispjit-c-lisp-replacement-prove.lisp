; Wave57 W1: lispjit.c Lisp 全替代证明 — 15link 全 13 模块（迁出前跑）.
; Prefix v45-rlcd- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (file-hash "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-rlcd-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rlcd-mod00.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-rlcd-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rlcd-mod04.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-rlcd-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rlcd-mod11.lbin")
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
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-abi.o"
                          "nano_mod_abi")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-manifest.o"
                          "nano_mod_manifest")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/09-run.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-run.o"
                          "nano_mod_run")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-pack.o"
                          "nano_mod_pack")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-ape.o"
                          "nano_mod_ape")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
                          "lab/nano-lisp-jit/.build/v45-rlcd-parse.o"
                          "nano_mod_parse")
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
                  "lab/nano-lisp-jit/.build/v45-rlcd-elf.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-abi.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-manifest.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-run.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-pack.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-ape.o"
                  "lab/nano-lisp-jit/.build/v45-rlcd-parse.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rlcd-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.codegen.lispjit_154kb_expand" "1")
  (file-hash "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"))
