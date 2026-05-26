; Wave48 W4: selfhost × nano-lisp.com bootstrap 矩阵 — 代际 com + 15link 子集.
; Prefix v45-slcbm- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-slcbm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-slcbm-min-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/v45-slcbm-next.com"
            "lab/nano-lisp-jit/.build/v45-slcbm-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-slcbm-min-x86.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-slcbm-next.com")
  (compile "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
           "lab/nano-lisp-jit/.build/v45-slcbm-mod10.lbin")
  (run "lab/nano-lisp-jit/.build/v45-slcbm-mod10.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-slcbm-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-slcbm-mod11.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.plan_only_terminal_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.nano_lisp_com.semantic_run" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-nano-lisp-com-bootstrap-terminal.lisp"))
