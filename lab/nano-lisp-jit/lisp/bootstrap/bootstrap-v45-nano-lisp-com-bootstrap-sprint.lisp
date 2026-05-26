; Wave61 W1: nano-lisp.com 自举冲刺 — pack + smoke + 15link 锚（零 .sh/.py 步骤）.
; Prefix v45-nlcbs- · no build-slice lispjit.c.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlcbs-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlcbs-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlcbs-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-nlcbs-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-nlcbs-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-nlcbs-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-nlcbs-smoke-strlen.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcbs-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcbs-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-nlcbs-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-nlcbs-main.o"
                  "lab/nano-lisp-jit/.build/v45-nlcbs-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlcbs-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.lisp_com.canonical" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.zero_cpysh" "1")
  (file-hash "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"))
