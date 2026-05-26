; Wave44 W3: 终局 daily 入口 — merge daily-semantic + nano-lisp.com terminal anchors.
; Prefix v45-cdt- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-semantic.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-semantic-run.lisp")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdt-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdt-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/v45-cdt-smoke-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdt-smoke-arithmetic.lbin")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-cdt-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdt-min-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com"
            "lab/nano-lisp-jit/.build/v45-cdt-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-cdt-min-x86.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdt-cl5-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdt-cl5-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdt-cl5-extra.o"
                          "nano_lispjit_extra")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdt-cl5-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdt-cl5-mf.o"
                          "nano_mf_mod")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdt-cl5-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdt-cl5-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdt-cl5-callee.o"
                  "lab/nano-lisp-jit/.build/v45-cdt-cl5-extra.o"
                  "lab/nano-lisp-jit/.build/v45-cdt-cl5-core.o"
                  "lab/nano-lisp-jit/.build/v45-cdt-cl5-mf.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdt-cl5-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_semantic" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.semantic_terminal_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-nano-lisp-com-terminal.json"))
