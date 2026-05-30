; Wave58 W3: v4.5 plan-only 外层 daily — zero-c + complete plan-only 合并（零 .sh/.py 步骤）.
; Prefix v45-cdpo- · no build-slice lispjit.c · no .sh · no python exec in plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-c.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-complete-plan-only.lisp")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdpo-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdpo-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdpo-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdpo-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdpo-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdpo-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdpo-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdpo-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdpo-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdpo-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_zero_c" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.host.sh_plan_only_replacement" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.lispjit_c_active_deleted" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-host-sh-retire.json"))
