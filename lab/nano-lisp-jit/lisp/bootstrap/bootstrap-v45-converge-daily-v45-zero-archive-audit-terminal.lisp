; Wave70 W3: v4.5 zero-archive-audit daily 终局 — COM+plan 零 archive/c 步骤.
; Prefix v45-cdzaat- · 用户 COM = nano-lisp.com + 本 plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-factory-honest-terminal.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-daily-zero-archive-audit-prove.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/lisp/core/nano-jit-slice-add.lisp")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/release/manifest.txt")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdzaat-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdzaat-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdzaat-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdzaat-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdzaat-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdzaat-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdzaat-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdzaat-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdzaat-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdzaat-linked" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/v45-cdzaat-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdzaat-add-x86.elf" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.seed_com_retired" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.scripts_zero_active_sh" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-daily-zero-archive-audit.json"))
