; v4.5 selfhost: lispjit-from-lisp module TU smoke on seed .com (plan 无 .c).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-mod00.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/02-compile.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-mod02.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-mod02.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-mod04.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-mod12.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"))
