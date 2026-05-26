; Wave53 W3: v4.5 物理 daily — zero-cpysh + 154KB 扩面 smoke（用户 plan-only）.
; Prefix v45-cdvp- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-zero-cpysh.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-lispjit-154kb-codegen-expand.lisp")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvp-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdvp-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdvp-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvp-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdvp-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdvp-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdvp-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdvp-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdvp-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_zero_cpysh" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.physical_zero_cpysh_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lispjit-154kb-codegen-expand.json"))
