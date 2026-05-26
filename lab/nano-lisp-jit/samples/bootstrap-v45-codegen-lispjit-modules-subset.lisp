; Wave34 W4: lispjit-modules 子集（00/04/12）VM smoke.
(bootstrap
  (compile "lab/nano-lisp-jit/samples/lispjit-modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-rc-sub-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rc-sub-mod00.lbin")
  (compile "lab/nano-lisp-jit/samples/lispjit-modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-rc-sub-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rc-sub-mod04.lbin")
  (compile "lab/nano-lisp-jit/samples/lispjit-modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-rc-sub-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rc-sub-mod12.lbin")
  (file-hash "lab/nano-lisp-jit/samples/lispjit-modules/12-parse.lisp"))
