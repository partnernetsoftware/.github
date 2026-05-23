; v3.5 gen4: Lisp-only slice steps (no nano-cc .c); pack x86 from Lisp slice, aarch64 genesis pin.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen4-slice-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen4-slice-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen4-slice-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen4-slice-add-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen4-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen4-slice-min-x86.elf"
            "lab/nano-lisp-jit/genesis/nano-jit.aarch64")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen4-nano-jit.com")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen4-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen4-arithmetic.lbin"))
