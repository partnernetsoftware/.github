; Mindmap DP loader-bare-default: NANO_PACK_APE_MODE=bare via pack-ape-bare-env.
(bootstrap
  (emit-elf64-exit "lab/nano-lisp-jit/.build/mindmap-bare-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/mindmap-bare-arm.elf" 7)
  (pack-ape-bare-env "lab/nano-lisp-jit/.build/mindmap-bare.com"
                     "lab/nano-lisp-jit/.build/mindmap-bare-x86.elf"
                     "lab/nano-lisp-jit/.build/mindmap-bare-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/mindmap-bare.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/mindmap-bare.com" 42))
