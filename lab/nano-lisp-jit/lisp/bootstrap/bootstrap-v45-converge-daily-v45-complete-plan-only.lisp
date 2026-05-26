; Wave54 W3: v4.5 完整 daily plan-only — physical + plan-only terminal + verify.
; Prefix v45-cdvcpo- · no .sh steps · no build-slice lispjit.c.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-plan-only-terminal.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-ci-plan-only-converge-chain.lisp")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvcpo-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvcpo-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvcpo-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvcpo-smoke-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvcpo-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvcpo-mod11.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvcpo-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvcpo-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdvcpo-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdvcpo-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdvcpo-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdvcpo-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_physical" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.codegen.lispjit_154kb_expand" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-ci-plan-only-converge.json"))
