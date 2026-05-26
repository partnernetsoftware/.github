; Wave52 W4: selfhost × v5 开卷矩阵.
; Prefix v45-svom- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-svom-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-svom-min-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-svom-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-svom-mod11.lbin")
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v2-broad.lisp")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-svom-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-svom-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.v45_terminal_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.codegen.lispjit_154kb_probe" "1")
  (file-hash "lab/nano-lisp-jit/v5/README.md"))
