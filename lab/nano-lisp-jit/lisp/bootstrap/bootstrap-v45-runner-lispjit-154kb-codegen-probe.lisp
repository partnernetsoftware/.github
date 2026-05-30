; Wave50 W1: 154KB lispjit codegen 探针 — 15link 全链 + 13 VM + 文件锚.
; Prefix v45-rl15- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (file-hash "lab/nano-lisp-jit/archive/c/runner/lispjit.c")
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-rl15-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rl15-mod00.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
           "lab/nano-lisp-jit/.build/v45-rl15-mod06.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rl15-mod06.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-rl15-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rl15-mod12.lbin")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-runner-codegen-full-chain.lisp")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-callee.lisp"
                          "lab/nano-lisp-jit/.build/v45-rl15-callee.o"
                          "nano_tu_callee")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-rl15-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-rl15-core.o"
                          "nano_mod_core")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
                          "lab/nano-lisp-jit/.build/v45-rl15-parse.o"
                          "nano_mod_parse")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-rl15-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-rl15-main.o"
                  "lab/nano-lisp-jit/.build/v45-rl15-callee.o"
                  "lab/nano-lisp-jit/.build/v45-rl15-core.o"
                  "lab/nano-lisp-jit/.build/v45-rl15-parse.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-rl15-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.codegen_full_chain" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.archive_runner_c" "1")
  (file-hash "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp"))
