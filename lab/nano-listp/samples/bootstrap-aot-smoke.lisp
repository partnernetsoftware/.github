; Bootstrap AOT smoke: let nano drive codegen and tiny-link executable checks.
(bootstrap
  (compile "lab/nano-listp/samples/arithmetic.lisp" "lab/nano-listp/.build/bootstrap-aot-arithmetic.lbin")
  (aot-elf64-exit "lab/nano-listp/.build/bootstrap-aot-arithmetic.lbin" "lab/nano-listp/.build/bootstrap-aot-arithmetic-exit.elf")
  (run-expect-exit "lab/nano-listp/.build/bootstrap-aot-arithmetic-exit.elf" 42)
  (aot-elf64-code "lab/nano-listp/.build/bootstrap-aot-arithmetic.lbin" "lab/nano-listp/.build/bootstrap-aot-arithmetic-code.elf")
  (run-expect-exit "lab/nano-listp/.build/bootstrap-aot-arithmetic-code.elf" 42)
  (compile-elf64-code "lab/nano-listp/samples/control-flow.lisp" "lab/nano-listp/.build/bootstrap-aot-control-flow.elf")
  (run-expect-exit "lab/nano-listp/.build/bootstrap-aot-control-flow.elf" 1)
  (compile-elf64-obj-code "lab/nano-listp/samples/multi-func-control-flow.lisp" "lab/nano-listp/.build/bootstrap-aot-multi-ctrl.o" "nano_bootstrap_multi_ctrl")
  (link-elf64-exe "lab/nano-listp/.build/bootstrap-aot-multi-ctrl-linked" "nano_bootstrap_multi_ctrl" "lab/nano-listp/.build/bootstrap-aot-multi-ctrl.o")
  (run-expect-exit "lab/nano-listp/.build/bootstrap-aot-multi-ctrl-linked" 43))
