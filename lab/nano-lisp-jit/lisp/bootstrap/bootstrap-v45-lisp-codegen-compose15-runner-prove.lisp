; Wave72 W1: plan-only compose-15link runner — 全 15 TU · exit 42（无 build-slice lispjit.c）.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-15chain.lisp")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-extra.o"
                          "nano_lispjit_extra")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-mf.o"
                          "nano_mf_mod")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-boot.o"
                          "nano_mod_boot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-vm.o"
                          "nano_mod_vm")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-aot.o"
                          "nano_mod_aot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-elf.o"
                          "nano_mod_elf")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-abi.o"
                          "nano_mod_abi")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-manifest.o"
                          "nano_mod_manifest")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/09-run.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-run.o"
                          "nano_mod_run")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-pack.o"
                          "nano_mod_pack")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-ape.o"
                          "nano_mod_ape")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rp-parse.o"
                          "nano_mod_parse")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-c15rp-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-c15rp-main.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-callee.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-extra.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-core.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-mf.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-boot.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-vm.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-aot.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-elf.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-abi.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-manifest.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-run.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-pack.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-ape.o"
                  "lab/nano-lisp-jit/.build/v45-c15rp-parse.o")
  (file-size "lab/nano-lisp-jit/.build/v45-c15rp-linked")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15rp-linked" 42)
  (file-hash "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"))
