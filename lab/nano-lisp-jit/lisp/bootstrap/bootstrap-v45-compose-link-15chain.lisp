; Wave42 W2: plan-only compose-15link — 15 .lisp TU → compile-elf64-obj-code → link-elf64-exe (exit 42).
; Prefix v45-cl15- · no build-slice lispjit.c · no .sh steps.
; mods[] order matches nano_bootstrap.c lispjit_from_lisp_build_compose_15link.
(bootstrap
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-callee.o"
                          "nano_tu_callee")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-callee.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-main.o"
                          "nano_tu_main")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-main.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-extra.o"
                          "nano_lispjit_extra")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-extra.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-core.o"
                          "nano_mod_core")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-core.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-mf.o"
                          "nano_mf_mod")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-mf.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-boot.o"
                          "nano_mod_boot")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-boot.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-vm.o"
                          "nano_mod_vm")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-vm.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-aot.o"
                          "nano_mod_aot")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-aot.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-elf.o"
                          "nano_mod_elf")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-elf.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-abi.o"
                          "nano_mod_abi")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-abi.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-manifest.o"
                          "nano_mod_manifest")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-manifest.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/09-run.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-run.o"
                          "nano_mod_run")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-run.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-pack.o"
                          "nano_mod_pack")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-pack.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-ape.o"
                          "nano_mod_ape")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-ape.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
                          "lab/nano-lisp-jit/.build/v45-cl15-parse.o"
                          "nano_mod_parse")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-parse.o")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cl15-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cl15-main.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-callee.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-extra.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-core.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-mf.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-boot.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-vm.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-aot.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-elf.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-abi.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-manifest.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-run.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-pack.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-ape.o"
                  "lab/nano-lisp-jit/.build/v45-cl15-parse.o")
  (file-size "lab/nano-lisp-jit/.build/v45-cl15-linked")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cl15-linked" 42)
  (file-hash "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"))
