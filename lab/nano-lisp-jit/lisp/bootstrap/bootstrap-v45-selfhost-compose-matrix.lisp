; Wave41 W4: selfhost compose matrix on lisp-only path.
; Prefix v45-scm- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-scm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-scm-min-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-scm-parse.lbin")
  (run "lab/nano-lisp-jit/.build/v45-scm-parse.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.daily_plan_continue.100" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.physical.modules_broad" "1")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-3chain.lisp"))
