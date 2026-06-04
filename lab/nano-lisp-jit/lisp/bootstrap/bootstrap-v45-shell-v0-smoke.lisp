; shell-v0 smoke — .lbin system() + bootstrap spawn-wait (dual shell path).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-v0-system.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-v0-system.lbin")
  (spawn-wait 0 "/bin/true")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-v0-bootstrap"))
