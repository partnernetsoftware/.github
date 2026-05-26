; Wave55 W3: v4.5 目标 daily — complete plan-only + physical 锚（零 .c/.sh/.py 步骤）.
; Prefix v45-cdvt- · no build-slice lispjit.c · no .sh · no python exec in plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-complete-plan-only.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical.lisp")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvt-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvt-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvt-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvt-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvt-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvt-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdvt-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdvt-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdvt-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdvt-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_complete_plan_only" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.codegen.lispjit_154kb_expand" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-tools-py-plan-only.json"))
