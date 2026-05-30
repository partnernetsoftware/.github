; Wave57 W3: v4.5 zero-c daily — Lisp 替代 + retired 锚（零 .c/.sh/.py 步骤）.
; Prefix v45-cdzc- · no build-slice lispjit.c · no .sh · no python exec in plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-target.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-lispjit-c-lisp-replacement-prove.lisp")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdzc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdzc-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdzc-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdzc-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdzc-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdzc-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdzc-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdzc-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdzc-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdzc-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_target" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.lispjit_c_lisp_replacement" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.lispjit_c_active_deleted" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lispjit-c-delete.json"))
