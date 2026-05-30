; Wave46 W3: codegen terminal daily — merge daily-physical-honest + 15link 全链锚.
; Prefix v45-cdct- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-physical-honest.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-codegen-full-chain.lisp")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdct-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdct-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cdct-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdct-smoke-arithmetic.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdct-cl5-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdct-cl5-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdct-cl5-extra.o"
                          "nano_lispjit_extra")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdct-cl5-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdct-cl5-mf.o"
                          "nano_mf_mod")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdct-cl5-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdct-cl5-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdct-cl5-callee.o"
                  "lab/nano-lisp-jit/.build/v45-cdct-cl5-extra.o"
                  "lab/nano-lisp-jit/.build/v45-cdct-cl5-core.o"
                  "lab/nano-lisp-jit/.build/v45-cdct-cl5-mf.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdct-cl5-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_physical_honest" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.physical_zero_c_honest_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-runner-codegen-terminal.json"))
