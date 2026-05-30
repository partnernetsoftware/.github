; Wave42 W3: daily converge + compose deep anchors — smoke subset + inline 3chain + W1/W2 path anchors.
; Merges: converge-daily-plan smoke (strlen+arith) + compose-link-3chain inline re-run.
; Prefix v45-cdc- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-plan.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-3chain.lisp")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdc-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cdc-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdc-smoke-arithmetic.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdc-cl3-callee.o"
                          "nano_tu_callee")
  (file-size "lab/nano-lisp-jit/.build/v45-cdc-cl3-callee.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdc-cl3-main.o"
                          "nano_tu_main")
  (file-size "lab/nano-lisp-jit/.build/v45-cdc-cl3-main.o")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdc-cl3-extra.o"
                          "nano_lispjit_extra")
  (file-size "lab/nano-lisp-jit/.build/v45-cdc-cl3-extra.o")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdc-cl3-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdc-cl3-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdc-cl3-callee.o"
                  "lab/nano-lisp-jit/.build/v45-cdc-cl3-extra.o")
  (file-size "lab/nano-lisp-jit/.build/v45-cdc-cl3-linked")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdc-cl3-linked" 42)
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-9chain.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-15chain.lisp")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.compose_modules_continue.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.daily_plan_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-compose-deep.json"))
