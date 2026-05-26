; mindmap L4 W2: bare loader（pack-ape-bare-env）.
(bootstrap
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-mm-bare-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-mm-bare-arm.elf" 7)
  (pack-ape-bare-env "lab/nano-lisp-jit/.build/v45-mm-bare.com"
                     "lab/nano-lisp-jit/.build/v45-mm-bare-x86.elf"
                     "lab/nano-lisp-jit/.build/v45-mm-bare-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-mm-bare.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-mm-bare.com" 42))
