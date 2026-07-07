; Wave68 W3: v4.5 Lisp 自举链 daily — COM+plan 零 .sh/.c/.py/archive 步骤.
; Prefix v45-cdlsbc- · 用户 COM = nano-lisp.com 自举链 promote.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-com-plan-only-terminal.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-lisp-selfhost-bootstrap-chain-prove.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/retired/com/nano-jit.com.archived")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdlsbc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdlsbc-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdlsbc-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdlsbc-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdlsbc-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdlsbc-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdlsbc-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdlsbc-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdlsbc-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdlsbc-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_com_plan_only_terminal" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.seed_com_retired" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.bootstrap_chain_promoted" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lisp-selfhost-bootstrap-chain.json"))
