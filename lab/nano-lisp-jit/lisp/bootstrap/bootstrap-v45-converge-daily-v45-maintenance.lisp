; Wave52 W3: v4.5 维护 daily — 终局 daily + v5 开卷锚 + verify 子集.
; Prefix v45-cdvm- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-complete.lisp")
  (file-size "lab/nano-lisp-jit/v5/README.md")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvm-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvm-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvm-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvm-smoke-arithmetic.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvm-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvm-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdvm-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdvm-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdvm-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdvm-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.v45_terminal_complete.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_complete" "1")
  (file-hash "lab/nano-lisp-jit/v5/README.md"))
