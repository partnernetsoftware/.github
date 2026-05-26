; Wave44 W1: nano-lisp.com 代际 semantic run — pack + 9link 子集 + genesis pin.
; Prefix v45-nlcsr- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlcsr-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlcsr-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlcsr-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-nlcsr-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-nlcsr-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcsr-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcsr-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcsr-extra.o"
                          "nano_lispjit_extra")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcsr-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcsr-mf.o"
                          "nano_mf_mod")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-nlcsr-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-nlcsr-main.o"
                  "lab/nano-lisp-jit/.build/v45-nlcsr-callee.o"
                  "lab/nano-lisp-jit/.build/v45-nlcsr-extra.o"
                  "lab/nano-lisp-jit/.build/v45-nlcsr-core.o"
                  "lab/nano-lisp-jit/.build/v45-nlcsr-mf.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlcsr-linked" 42)
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-hash "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.semantic_terminal" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.canonical" "1"))
