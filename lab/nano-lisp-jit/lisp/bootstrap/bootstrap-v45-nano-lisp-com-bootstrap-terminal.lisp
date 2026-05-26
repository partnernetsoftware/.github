; Wave48 W1: nano-lisp.com 自举终局 — pack + 15link + genesis + 全模块锚.
; Prefix v45-nlcbt- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlcbt-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlcbt-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlcbt-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-nlcbt-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-nlcbt-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-codegen-full-chain.lisp")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcbt-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcbt-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcbt-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcbt-parse.o"
                          "nano_mod_parse")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-nlcbt-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-nlcbt-main.o"
                  "lab/nano-lisp-jit/.build/v45-nlcbt-callee.o"
                  "lab/nano-lisp-jit/.build/v45-nlcbt-core.o"
                  "lab/nano-lisp-jit/.build/v45-nlcbt-parse.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlcbt-linked" 42)
  (file-hash "lab/nano-lisp-jit/genesis/nano-jit.x86_64")
  (file-hash "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.codegen_full_chain" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.canonical" "1"))
