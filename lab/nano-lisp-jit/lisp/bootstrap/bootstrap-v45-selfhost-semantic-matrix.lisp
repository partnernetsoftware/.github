; Wave43 W4: selfhost semantic matrix on lisp-only path.
; Prefix v45-ssm- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-ssm-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-ssm-min-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-ssm-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-ssm-mod11.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-ssm-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-ssm-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.compose_9link" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.compose_15link" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.selfhost.100" "1")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-semantic-terminal-proof.lisp"))
