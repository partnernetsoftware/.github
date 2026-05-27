; Wave49 W4: selfhost × endgame 诚实矩阵 — 代际 com + Wave48 锚.
; Prefix v45-sehm- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-sehm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-sehm-min-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-sehm-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sehm-mod11.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-sehm-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sehm-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.lisp_com_bootstrap_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.goal.onion_tdd_tree_mindmap.100" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-endgame-waves-44-48-rollup.lisp"))
