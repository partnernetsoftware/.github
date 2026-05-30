; Wave52 W3: 零 cpysh daily — merge v45-complete + zero-host-sh（用户 plan-only）.
; Prefix v45-cdzc- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-complete.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-zero-host-sh.lisp")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdzc-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdzc-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cdzc-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdzc-smoke-arithmetic.lbin")
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
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_complete" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_zero_host_sh" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-physical-zero-cpysh-continue.json"))
