; Wave61 W4: selfhost × physical-honest-terminal 矩阵.
; Prefix v45-sphtm- · no build-slice lispjit.c · no .sh · no .py steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/retired/lispjit.c.archived")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-sphtm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-sphtm-min-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-sphtm-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sphtm-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.ci_shell_retire_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.nano_lisp_com.bootstrap_sprint" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-nano-lisp-com.lisp"))
