; v4.5 product feedback rollup: gap probes + doc anchor (plan 无 .sh).
(bootstrap
  (file-size "lab/nano-lisp-jit/v4.5/PRODUCT-FEEDBACK.md")
  (compile "lab/nano-lisp-jit/samples/boundary/func-block-vm-gap.lisp"
           "lab/nano-lisp-jit/.build/v45-feedback-func-block.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/samples/boundary/func-block-vm-gap.lisp"
                     "lab/nano-lisp-jit/.build/v45-feedback-func-block.elf"
                     "nano_v45_fb_block")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-feedback-func-block.elf" 42)
  (compile "lab/nano-lisp-jit/samples/boundary/bool-not.lisp"
           "lab/nano-lisp-jit/.build/v45-feedback-bool-not.lbin")
  (run "lab/nano-lisp-jit/.build/v45-feedback-bool-not.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/cmp-le-ge.lisp"
           "lab/nano-lisp-jit/.build/v45-feedback-cmp-le-ge.lbin")
  (run "lab/nano-lisp-jit/.build/v45-feedback-cmp-le-ge.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/store-u16-mutate.lisp"
           "lab/nano-lisp-jit/.build/v45-feedback-store-u16.lbin")
  (run "lab/nano-lisp-jit/.build/v45-feedback-store-u16.lbin")
  (file-hash "lab/nano-lisp-jit/v4.5/PRODUCT-FEEDBACK.md"))
