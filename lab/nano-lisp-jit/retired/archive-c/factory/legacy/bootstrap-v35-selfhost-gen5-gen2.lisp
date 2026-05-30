; v3.5 L4-runner-1: gen2 slice runs gen5 subset (x86 Lisp min; aarch64 genesis pin — gen2 no aarch64 lisp).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5g2-slice-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5g2-slice-min-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5g2-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5g2-slice-min-x86.elf"
            "lab/nano-lisp-jit/genesis/nano-jit.aarch64")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5g2-nano-jit.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5g2-arithmetic.lbin"))
