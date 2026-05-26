; Wave64 W1: archive/c runner C 退仓证明 — 15link 经 lisp/core（零 archive/c 步骤）.
; Prefix v45-acfrp- · no .sh/.py steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/retired/archive-c/runner/README.md")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-acfrp-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-acfrp-smoke-strlen.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-acfrp-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-acfrp-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-acfrp-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-acfrp-main.o"
                  "lab/nano-lisp-jit/.build/v45-acfrp-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-acfrp-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.nano_lisp_com.native_bootstrap" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.zero_cpysh" "1")
  (file-hash "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"))
