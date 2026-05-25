; v4.5 boundary probe: explore nano-jit.com VM limits (plan 无 .c/.sh).
(bootstrap
  (compile "lab/nano-lisp-jit/samples/boundary/add-i64-chain.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-add-i64.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-add-i64.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/cmp-i64-ops.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-cmp-i64.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-cmp-i64.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/nested-func-call.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-nested.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-nested.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/branch-merge.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-branch.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-branch.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/store-load-u8.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-store-u8.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-store-u8.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/samples/boundary/nested-func-call.lisp"
                     "lab/nano-lisp-jit/.build/v45-boundary-nested.elf"
                     "nano_v45_nested")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-boundary-nested.elf" 42)
  (file-hash "lab/nano-lisp-jit/samples/boundary/add-i64-chain.lisp"))
