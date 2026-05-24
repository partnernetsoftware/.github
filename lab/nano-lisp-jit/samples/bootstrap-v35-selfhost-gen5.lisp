; v3.5 gen5: zero .c; dual-arch Lisp slices; pack without genesis pin paths.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-add-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-min-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-add-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-min-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-min-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-nano-jit.com")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-min-x86.elf")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5-slice-min-aarch64.elf"))
