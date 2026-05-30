; Wave72 W3: compose15-runner-promote daily — plan-only · release COM 锚.
(bootstrap
  (file-size "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-compose15-runner-promote.json")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-lisp-codegen-compose15-runner-prove.lisp")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-c15rd-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-c15rd-smoke-strlen.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rd-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-c15rd-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-c15rd-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-c15rd-main.o"
                  "lab/nano-lisp-jit/.build/v45-c15rd-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15rd-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.lisp_codegen_diffuse_continue.100" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-compose15-runner-promote.json"))
