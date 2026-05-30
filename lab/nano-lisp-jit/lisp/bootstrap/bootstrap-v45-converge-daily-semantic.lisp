; Wave43 W3: daily converge升维 — merge daily-compose + semantic anchors.
; Merges: converge-daily-plan smoke (strlen+arith) + compose-link-9chain inline 5link + semantic path anchors.
; Prefix v45-cds- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-plan.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-semantic-terminal-proof.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-modules-full-13.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cds-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cds-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cds-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cds-smoke-arithmetic.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-cds-cl5-callee.o"
                          "nano_tu_callee")
  (file-size "lab/nano-lisp-jit/.build/v45-cds-cl5-callee.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cds-cl5-main.o"
                          "nano_tu_main")
  (file-size "lab/nano-lisp-jit/.build/v45-cds-cl5-main.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-cds-cl5-extra.o"
                          "nano_lispjit_extra")
  (file-size "lab/nano-lisp-jit/.build/v45-cds-cl5-extra.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cds-cl5-core.o"
                          "nano_mod_core")
  (file-size "lab/nano-lisp-jit/.build/v45-cds-cl5-core.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-cds-cl5-mf.o"
                          "nano_mf_mod")
  (file-size "lab/nano-lisp-jit/.build/v45-cds-cl5-mf.o")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cds-cl5-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cds-cl5-main.o"
                  "lab/nano-lisp-jit/.build/v45-cds-cl5-callee.o"
                  "lab/nano-lisp-jit/.build/v45-cds-cl5-extra.o"
                  "lab/nano-lisp-jit/.build/v45-cds-cl5-core.o"
                  "lab/nano-lisp-jit/.build/v45-cds-cl5-mf.o")
  (file-size "lab/nano-lisp-jit/.build/v45-cds-cl5-linked")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cds-cl5-linked" 42)
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-9chain.lisp")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.daily_plan_continue.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.compose_deep_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-semantic-terminal.json"))
