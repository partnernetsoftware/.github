; APE v2 Mode A (pack-ape + marker) and Mode B (pack-ape-bare, header at offset 0).

(bootstrap
  (emit-elf64-exit "lab/nano-lisp-jit/.build/bootstrap-ape-v2-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/bootstrap-ape-v2-arm.elf" 7)
  (pack-ape "lab/nano-lisp-jit/.build/bootstrap-ape-v2.com" "lab/nano-lisp-jit/.build/bootstrap-ape-v2-x86.elf" "lab/nano-lisp-jit/.build/bootstrap-ape-v2-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/bootstrap-ape-v2.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/bootstrap-ape-v2.com" 42)
  (pack-ape-bare "lab/nano-lisp-jit/.build/bootstrap-ape-v2-bare.com" "lab/nano-lisp-jit/.build/bootstrap-ape-v2-x86.elf" "lab/nano-lisp-jit/.build/bootstrap-ape-v2-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/bootstrap-ape-v2-bare.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/bootstrap-ape-v2-bare.com" 42))
