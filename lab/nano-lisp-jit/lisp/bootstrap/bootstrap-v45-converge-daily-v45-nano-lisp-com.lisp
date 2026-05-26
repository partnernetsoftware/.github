; Wave61 W3: v4.5 nano-lisp.com daily — physical zero-cpysh + 自举产物（零 .c/.sh/.py 步骤）.
; Prefix v45-cdnlc- · user COM = nano-lisp.com.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-physical-zero-cpysh.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-bootstrap-sprint.lisp")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdnlc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdnlc-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdnlc-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdnlc-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdnlc-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdnlc-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdnlc-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdnlc-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdnlc-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdnlc-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_physical_zero_cpysh" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.nano_lisp_com.bootstrap_sprint" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.zero_cpysh" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-physical-honest-terminal.json"))
