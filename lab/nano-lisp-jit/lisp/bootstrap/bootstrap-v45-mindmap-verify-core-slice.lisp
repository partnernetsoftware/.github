; mindmap L4 W3: verify-core 切片（ptr + multi-func AOT）.
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/core/ptr-values.lisp"
           "lab/nano-lisp-jit/.build/v45-mm-ptr.lbin")
  (run "lab/nano-lisp-jit/.build/v45-mm-ptr.lbin")
  (compile-elf64-exe "lab/nano-lisp-jit/lisp/core/multi-func.lisp"
                     "lab/nano-lisp-jit/.build/v45-mm-multi.elf"
                     "nano_v45_mm_multi")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-mm-multi.elf" 43)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-mm-exit43.elf" 43)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-mm-exit43.elf" 43))
