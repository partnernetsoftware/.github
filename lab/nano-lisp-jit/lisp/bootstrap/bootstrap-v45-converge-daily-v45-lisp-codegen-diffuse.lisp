; Wave71 W3: lisp-codegen 扩散 daily — plan-only · compose-15 + verify 锚.
(bootstrap
  (file-size "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lisp-codegen-diffuse.json")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-lisp-codegen-compose15-prove.lisp")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-clcd-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-clcd-smoke-strlen.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-clcd-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-clcd-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-clcd-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-clcd-main.o"
                  "lab/nano-lisp-jit/.build/v45-clcd-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-clcd-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.terminal_done" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-lisp-codegen-diffuse.json"))
