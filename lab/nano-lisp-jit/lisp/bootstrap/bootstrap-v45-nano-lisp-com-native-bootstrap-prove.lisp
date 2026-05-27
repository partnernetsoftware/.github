; Wave63 W1: nano-lisp.com 原生 bootstrap 证明 — host 种子 promote 前跑（零 .sh/.py 步骤）.
; Prefix v45-nlcnbs- · run on nano-lisp-host.com before promote.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp-host.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlcnbs-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlcnbs-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-nlcnbs-ir-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/release/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-nlcnbs-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-nlcnbs-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/release/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-nlcnbs-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-nlcnbs-smoke-strlen.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcnbs-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-nlcnbs-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-nlcnbs-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-nlcnbs-main.o"
                  "lab/nano-lisp-jit/.build/v45-nlcnbs-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-nlcnbs-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.host.com_nano_lisp_only" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.nano_lisp_com.bootstrap_sprint" "1")
  (file-hash "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp-host.com"))
