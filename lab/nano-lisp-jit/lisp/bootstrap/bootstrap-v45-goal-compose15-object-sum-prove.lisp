; Wave78 W3: 15 TU object 链 + link · plan-only 无 build-slice lispjit.c.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-15chain.lisp")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-extra.o"
                          "nano_lispjit_extra")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-mf.o"
                          "nano_mf_mod")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-boot.o"
                          "nano_mod_boot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-vm.o"
                          "nano_mod_vm")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-aot.o"
                          "nano_mod_aot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-elf.o"
                          "nano_mod_elf")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-abi.o"
                          "nano_mod_abi")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-manifest.o"
                          "nano_mod_manifest")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/09-run.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-run.o"
                          "nano_mod_run")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-pack.o"
                          "nano_mod_pack")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-ape.o"
                          "nano_mod_ape")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15fc78-parse.o"
                          "nano_mod_parse")
  (file-size "lab/nano-lisp-jit/.build/v45-c15fc78-main.o")
  (file-size "lab/nano-lisp-jit/.build/v45-c15fc78-callee.o")
  (file-size "lab/nano-lisp-jit/.build/v45-c15fc78-core.o")
  (file-size "lab/nano-lisp-jit/.build/v45-c15fc78-vm.o")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-c15fc78-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-main.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-callee.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-extra.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-core.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-mf.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-boot.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-vm.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-aot.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-elf.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-abi.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-manifest.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-run.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-pack.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-ape.o"
                  "lab/nano-lisp-jit/.build/v45-c15fc78-parse.o")
  (file-size "lab/nano-lisp-jit/.build/v45-c15fc78-linked")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15fc78-linked" 42)
  (file-hash "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"))
