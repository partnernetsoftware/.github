; v4.5 boundary probe: explore nano-jit.com VM limits (plan 无 .c/.sh).
(bootstrap
  (compile "lab/nano-lisp-jit/samples/boundary/add-i64-chain.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-add-i64.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-add-i64.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/cmp-i64-ops.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-cmp-i64.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-cmp-i64.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/i64-mul-chain.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-mul-i64.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-mul-i64.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/nested-func-call.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-nested.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-nested.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/func-param-chain.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-func-param.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-func-param.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/branch-merge.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-branch.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-branch.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/multi-func-call.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-mfcall.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-mfcall.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/store-load-u8.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-store-u8.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-store-u8.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/load-u16-rodata.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-load-u16.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-load-u16.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/ptr-null-arith.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-ptr.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-ptr.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/bool-not.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-bool-not.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-bool-not.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/cmp-le-ge.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-cmp-le-ge.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-cmp-le-ge.lbin")
  (compile "lab/nano-lisp-jit/samples/boundary/store-u16-mutate.lisp"
           "lab/nano-lisp-jit/.build/v45-boundary-store-u16.lbin")
  (run "lab/nano-lisp-jit/.build/v45-boundary-store-u16.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/samples/boundary/nested-func-call.lisp"
                     "lab/nano-lisp-jit/.build/v45-boundary-nested.elf"
                     "nano_v45_nested")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-boundary-nested.elf" 42)
  (compile-elf64-exe "lab/nano-lisp-jit/samples/boundary/multi-func-call.lisp"
                     "lab/nano-lisp-jit/.build/v45-boundary-mfcall.elf"
                     "nano_v45_mfcall")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-boundary-mfcall.elf" 43)
  (file-hash "lab/nano-lisp-jit/samples/boundary/README.md"))
