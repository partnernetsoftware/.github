; v4.5 boundary negative: VM/AOT must reject bad forms (plan 无 .sh).
(bootstrap
  (compile-expect-exit 2 compile "lab/nano-lisp-jit/samples/func-param-missing-param-bad.lisp"
                       "lab/nano-lisp-jit/.build/v45-boundary-bad-missing-param.lbin")
  (compile-expect-exit 2 compile "lab/nano-lisp-jit/samples/func-param-call-no-arg-bad.lisp"
                       "lab/nano-lisp-jit/.build/v45-boundary-bad-call-no-arg.lbin")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-load-u8-bad.lisp"
                       "lab/nano-lisp-jit/.build/v45-boundary-bad-load-u8.elf"
                       "nano_v45_bad_load_u8")
  (compile-expect-exit 2 compile-elf64-exe "lab/nano-lisp-jit/samples/type-error-ptr-op-bad.lisp"
                       "lab/nano-lisp-jit/.build/v45-boundary-bad-ptr-op.elf"
                       "nano_v45_bad_ptr_op")
  (file-hash "lab/nano-lisp-jit/samples/boundary/i64-mul-chain.lisp"))
