; v3.5 Lisp-only L1: pack-ape x86 slice from Lisp-built ELF; aarch64 from genesis pin.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86-slice.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86-slice.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86.com"
            "lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86-slice.elf"
            "lab/nano-lisp-jit/genesis/nano-jit.aarch64")
  (inspect-ape "lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86.com")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/bootstrap-v35-pack-lisp-x86-arithmetic.lbin"))
