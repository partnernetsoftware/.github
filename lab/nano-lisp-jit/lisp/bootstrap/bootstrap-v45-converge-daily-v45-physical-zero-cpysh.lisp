; Wave60 W3: v4.5 physical zero-cpysh daily — 终局用户 plan（零 .c/.sh/.py 步骤）.
; Prefix v45-cdpzc- · no build-slice lispjit.c · no .sh · no python exec in plan.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-cpysh-terminal.lisp")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (file-size "lab/nano-lisp-jit/retired/tools/mindmap-dp-v45.py")
  (file-size "lab/nano-lisp-jit/retired/scripts/v45-wave59-tools-py-retire-converge.sh")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdpzc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdpzc-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdpzc-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdpzc-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdpzc-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdpzc-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdpzc-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdpzc-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdpzc-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdpzc-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_zero_cpysh_terminal" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.ci.shell_plan_only_replacement" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.tools.py_active_deleted" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-ci-shell-retire.json"))
