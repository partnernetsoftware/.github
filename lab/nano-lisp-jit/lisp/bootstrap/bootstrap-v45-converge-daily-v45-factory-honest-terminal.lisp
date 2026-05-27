; Wave69 W3: v4.5 工厂诚实 daily 终局 — COM+plan 零 archive/c 路径 · 仅 lisp/core + lisp/modules.
; Prefix v45-cdfht- · 用户 COM = nano-lisp.com + 本 plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-lisp-selfhost-bootstrap-chain.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-run-sh-factory-honest-prove.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/retired/com/nano-jit.com.archived")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdfht-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdfht-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdfht-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdfht-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdfht-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdfht-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdfht-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdfht-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdfht-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdfht-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.seed_com_retired" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.scripts_zero_active_sh" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-run-sh-archive-honest.json"))
