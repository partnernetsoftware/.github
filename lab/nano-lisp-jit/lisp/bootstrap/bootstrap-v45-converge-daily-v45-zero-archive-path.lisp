; Wave66 W3: v4.5 zero-archive-path daily — 用户 plan 零 archive/c 路径（零 .c/.sh/.py 步骤）.
; Prefix v45-cdzap- · COM = nano-lisp.com · 全 lisp/ 树.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-plan-only-final.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-archive-factory-lisp-retire-prove.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdzap-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdzap-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdzap-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdzap-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdzap-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdzap-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdzap-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdzap-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdzap-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdzap-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_plan_only_final" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.archive_factory_lisp_retired" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.zero_cpysh" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-archive-factory-lisp-retire.json"))
