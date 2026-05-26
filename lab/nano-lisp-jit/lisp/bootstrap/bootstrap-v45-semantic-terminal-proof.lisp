; Wave43 W2: semantic-terminal proof — 9link 子集 + genesis pin 锚（plan-only）.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-15chain.lisp")
  (file-size "lab/nano-lisp-jit/v4.5/HONEST-REMAINING.md")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-stp-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-stp-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-stp-extra.o"
                          "nano_lispjit_extra")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-stp-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-stp-mf.o"
                          "nano_mf_mod")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
                          "lab/nano-lisp-jit/.build/v45-stp-boot.o"
                          "nano_mod_boot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
                          "lab/nano-lisp-jit/.build/v45-stp-vm.o"
                          "nano_mod_vm")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
                          "lab/nano-lisp-jit/.build/v45-stp-aot.o"
                          "nano_mod_aot")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
                          "lab/nano-lisp-jit/.build/v45-stp-elf.o"
                          "nano_mod_elf")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-stp-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-stp-main.o"
                  "lab/nano-lisp-jit/.build/v45-stp-callee.o"
                  "lab/nano-lisp-jit/.build/v45-stp-extra.o"
                  "lab/nano-lisp-jit/.build/v45-stp-core.o"
                  "lab/nano-lisp-jit/.build/v45-stp-mf.o"
                  "lab/nano-lisp-jit/.build/v45-stp-boot.o"
                  "lab/nano-lisp-jit/.build/v45-stp-vm.o"
                  "lab/nano-lisp-jit/.build/v45-stp-aot.o"
                  "lab/nano-lisp-jit/.build/v45-stp-elf.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-stp-linked" 42)
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.compose_15link" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.compose_deep_continue.100" "1"))
