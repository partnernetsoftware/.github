; Wave46 W1: 154KB runner codegen 全链 — 15link 全模块 + 13 VM smoke.
; Prefix v45-rcfc- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-rcfc-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rcfc-mod00.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-rcfc-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rcfc-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-extra.o"
                          "nano_lispjit_extra")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-mf.o"
                          "nano_mf_mod")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-boot.o"
                          "nano_mod_boot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-vm.o"
                          "nano_mod_vm")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-aot.o"
                          "nano_mod_aot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-elf.o"
                          "nano_mod_elf")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-abi.o"
                          "nano_mod_abi")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-manifest.o"
                          "nano_mod_manifest")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/09-run.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-run.o"
                          "nano_mod_run")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-pack.o"
                          "nano_mod_pack")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-ape.o"
                          "nano_mod_ape")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
                          "lab/nano-lisp-jit/.build/v45-rcfc-parse.o"
                          "nano_mod_parse")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-rcfc-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-rcfc-main.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-callee.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-extra.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-core.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-mf.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-boot.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-vm.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-aot.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-elf.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-abi.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-manifest.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-run.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-pack.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-ape.o"
                  "lab/nano-lisp-jit/.build/v45-rcfc-parse.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rcfc-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.lispjit_codegen_deep" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.compose_15link" "1")
  (file-hash "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"))
