; shell-com-only — release/nano-lisp.com + lisp/shell/*.lisp only.
; No archive/c embed, no Rust nanolisp binary, no .sh bootstrap steps.
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-com-only-v0.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-com-only-v0.lbin")

  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-com-only-script.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-com-only-script.lbin")

  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-com-only-script2.lbin")
  (compare "lab/nano-lisp-jit/.build/v45-shell-com-only-script.lbin"
           "lab/nano-lisp-jit/.build/v45-shell-com-only-script2.lbin")

  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com")

  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "compile"
    "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
    "lab/nano-lisp-jit/.build/v45-shell-com-only-com.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run"
    "lab/nano-lisp-jit/.build/v45-shell-com-only-com.lbin")

  (compile "lab/nano-lisp-jit/lisp/shell/shell-fgets-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-com-only-fgets.lbin")
  (run-stdin "piped-fgets-line\n"
    "lab/nano-lisp-jit/.build/v45-shell-com-only-fgets.lbin"))
