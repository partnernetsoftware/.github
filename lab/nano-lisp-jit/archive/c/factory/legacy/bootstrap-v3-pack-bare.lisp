; v3: pack-ape via NANO_PACK_APE_MODE=bare (bootstrap DSL pack-ape-bare-env).

(bootstrap
  (emit-elf64-exit "lab/nano-lisp-jit/.build/bootstrap-v3-pack-bare-x86.elf" 42)
  (emit-elf64-exit "lab/nano-lisp-jit/.build/bootstrap-v3-pack-bare-arm.elf" 7)
  (pack-ape-bare-env "lab/nano-lisp-jit/.build/bootstrap-v3-pack-bare.com" "lab/nano-lisp-jit/.build/bootstrap-v3-pack-bare-x86.elf" "lab/nano-lisp-jit/.build/bootstrap-v3-pack-bare-arm.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/bootstrap-v3-pack-bare.com")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v3-pack-bare.com" 42))
