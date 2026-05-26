; Wave42 W4: selfhost compose deep matrix on lisp-only path.
; Prefix v45-scd- · no build-slice lispjit.c · no .sh steps.
(bootstrap
  (file-size "lab/nano-lisp-jit/.build/v45-selfhost-next.com")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-scd-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-scd-min-x86.elf" 42)
  (compile "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
           "lab/nano-lisp-jit/.build/v45-scd-mod07.lbin")
  (run "lab/nano-lisp-jit/.build/v45-scd-mod07.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-scd-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-scd-mod12.lbin")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.compose_3link" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.runner.compose_5link" "1")
  (results-min "lab/nano-lisp-jit/.build/v45-entry.evidence" "v45.v45.compose_modules_continue.100" "1")
  (file-size "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-compose-link-9chain.lisp"))
