; Wave51 W3: v4.5 终局 daily — merge endgame + codegen dedicated + verify 子集.
; Prefix v45-cdvc- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-endgame.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-codegen-dedicated.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-v45-extension-waves-rollup-all.lisp")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvc-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvc-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvc-smoke-arithmetic.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvc-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvc-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdvc-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdvc-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdvc-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdvc-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.scoped.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.release.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-v45-terminal-complete.json"))
