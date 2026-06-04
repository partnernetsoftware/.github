; shell-script smoke — multi-step .lbin + bootstrap spawn chain.
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-script.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-script.lbin")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-script-bootstrap")
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (spawn-wait 0 "/bin/true"))
