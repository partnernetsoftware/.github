; Wave66 W4: selfhost × archive factory lisp retire 矩阵.
; Prefix v45-saflrm- · no build-slice lispjit.c · no .sh · no .py steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/.build/nano-lisp/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/retired/archive-c/factory/misc/lisp-tu-main.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-saflrm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-saflrm-min-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-saflrm-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-saflrm-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.ci_sh_final_retire_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.archive_factory_lisp_retired" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-zero-archive-path.lisp"))
