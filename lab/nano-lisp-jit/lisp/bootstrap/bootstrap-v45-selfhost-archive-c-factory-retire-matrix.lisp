; Wave64 W4: selfhost × archive-c factory retire 矩阵.
; Prefix v45-sacfrm- · no build-slice lispjit.c · no .sh · no .py steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/release/v45-selfhost-next.com")
  (file-size "lab/nano-lisp-jit/release/nano-lisp.com")
  (file-size "lab/nano-lisp-jit/lisp/core/lisp-tu-main.lisp")
  (file-size "lab/nano-lisp-jit/retired/archive-c/runner/nano_bootstrap.c")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-sacfrm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-sacfrm-min-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-sacfrm-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sacfrm-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.nano_lisp_com_native_matrix" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.honest.archive_c_runner_retired" "1")
  (file-hash "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-converge-daily-v45-lisp-only-factory.lisp"))
