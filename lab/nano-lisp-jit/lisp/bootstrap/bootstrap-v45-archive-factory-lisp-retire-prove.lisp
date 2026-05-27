; Wave66 W1: archive/c factory lisp 退仓证明 — 15link 全 lisp/ 路径（零 archive/c 步骤）.
; Prefix v45-aflrp- · no .sh/.py steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/retired/archive-c/factory/misc/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/retired/archive-c/runner/README.md")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-aflrp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-aflrp-smoke-strlen.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-aflrp-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-aflrp-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-aflrp-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-aflrp-main.o"
                  "lab/nano-lisp-jit/.build/v45-aflrp-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-aflrp-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_plan_only_final" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.ci.utility_sh_retired" "1")
  (file-hash "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"))
