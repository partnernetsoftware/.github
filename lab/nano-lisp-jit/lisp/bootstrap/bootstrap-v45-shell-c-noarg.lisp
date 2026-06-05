; shell-c-noarg — C COM + lisp/shell only (rodata no-arg + compile/run).
(bootstrap
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "compile"
    "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
    "lab/nano-lisp-jit/.build/v45-shell-c-noarg.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run"
    "lab/nano-lisp-jit/.build/v45-shell-c-noarg.lbin"))
