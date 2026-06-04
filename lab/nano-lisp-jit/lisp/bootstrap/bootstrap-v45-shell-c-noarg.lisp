; shell-c-noarg — C track no-arg: release COM GAP + compile/run shell-script via subcommands.
; Host cc runner (argc==1) is exercised by nano-jit-c-shell-noarg-smoke.sh (NANO_C_HOST_RUNNER).
(bootstrap
  ; Pinned release COM: pre-promote still usage exit 2.
  (spawn-wait 2 "lab/nano-lisp-jit/release/nano-lisp.com")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "compile"
    "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
    "lab/nano-lisp-jit/.build/v45-shell-c-noarg.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run"
    "lab/nano-lisp-jit/.build/v45-shell-c-noarg.lbin"))
