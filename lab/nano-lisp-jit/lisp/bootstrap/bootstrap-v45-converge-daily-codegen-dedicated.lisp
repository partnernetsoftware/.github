; Wave50 W3: codegen dedicated daily — merge endgame + 154KB 探针.
; Prefix v45-cdcd- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-endgame.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-lispjit-154kb-codegen-probe.lisp")
  (file-size "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdcd-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdcd-smoke-strlen.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdcd-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdcd-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdcd-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdcd-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdcd-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdcd-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.rollup.waves_44_48" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.endgame_honest_rollup_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lispjit-codegen-dedicated.json"))
