; Wave62 W3: v4.5 nano-lisp.com host daily — COM 路径统一 nano-lisp/ 树（零 .c/.sh/.py 步骤）.
; Prefix v45-cdnlch- · user COM = nano-lisp-host.com under nano-lisp/.
(bootstrap
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-nano-lisp-com.lisp")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-host-unify-prove.lisp")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp-host.com")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (squad-dispatch "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (squad-assess "lab/nano-lisp-jit/squad/catalog-v45.yaml")
  (compile "lab/nano-lisp-jit/lisp/core/strlen.lisp"
           "lab/nano-lisp-jit/.build/v45-cdnlch-smoke-strlen.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdnlch-smoke-strlen.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-cdnlch-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-cdnlch-mod12.lbin")
  (compile-elf64-obj-code "lab/nano-lisp-jit/archive/c/factory/misc/lisp-tu-main.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdnlch-main.o"
                          "nano_tu_main")
  (compile-elf64-obj-code "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
                          "lab/nano-lisp-jit/.build/v45-cdnlch-core.o"
                          "nano_mod_core")
  (link-elf64-exe "lab/nano-lisp-jit/.build/v45-cdnlch-linked"
                  "nano_tu_main"
                  "lab/nano-lisp-jit/.build/v45-cdnlch-main.o"
                  "lab/nano-lisp-jit/.build/v45-cdnlch-core.o")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-cdnlch-linked" 42)
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.converge.daily_v45_nano_lisp_com" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.host.com_nano_lisp_only" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.nano_lisp_com.bootstrap_sprint" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.physical.zero_cpysh" "1")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-nano-lisp-com-host-only.json"))
