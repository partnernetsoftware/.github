; v4.5 fine concurrent · track A3: func domain (plan 无 .sh).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/boundary/nested-func-call.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-func-nested.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-func-nested.lbin")
  (compile "lab/nano-lisp-jit/lisp/boundary/func-param-chain.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-func-param.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-func-param.lbin")
  (compile "lab/nano-lisp-jit/lisp/boundary/multi-func-call.lisp"
           "lab/nano-lisp-jit/.build/v45-fine-func-mfcall.lbin")
  (run "lab/nano-lisp-jit/.build/v45-fine-func-mfcall.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/lisp/boundary/multi-func-call.lisp"
                     "lab/nano-lisp-jit/.build/v45-fine-func-mfcall.elf"
                     "nano_v45_fine_mfcall")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-fine-func-mfcall.elf" 43)
  (compile-elf64-exe "lab/nano-lisp-jit/lisp/boundary/func-block-vm-gap.lisp"
                     "lab/nano-lisp-jit/.build/v45-fine-func-block.elf"
                     "nano_v45_fine_block")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-fine-func-block.elf" 42))
