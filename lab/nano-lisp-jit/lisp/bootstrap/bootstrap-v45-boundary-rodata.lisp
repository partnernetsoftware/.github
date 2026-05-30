; v4.5 fine concurrent · track A4: rodata / bool domain (plan 无 .sh).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/boundary/store-load-u8.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-rodata-u8.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-rodata-u8.lbin")
  (compile "lab/nano-lisp-jit/lisp/boundary/load-u16-rodata.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-rodata-u16.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-rodata-u16.lbin")
  (compile "lab/nano-lisp-jit/lisp/boundary/store-u16-mutate.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-rodata-mutate.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-rodata-mutate.lbin")
  (compile "lab/nano-lisp-jit/lisp/boundary/bool-not.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-rodata-bool.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-rodata-bool.lbin")
  (compile "lab/nano-lisp-jit/lisp/boundary/branch-merge.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-rodata-branch.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-rodata-branch.lbin"))
