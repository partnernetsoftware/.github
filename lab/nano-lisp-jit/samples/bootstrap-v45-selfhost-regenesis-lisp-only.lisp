; v4.5 factory: regenesis 零 plan 内 lispjit.c（仅 build-slice-lisp）.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-regen-lo-ir-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/v45-regen-lo-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-regen-lo-min-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/v45-next-lisp-only.com"
            "lab/nano-lisp-jit/.build/v45-regen-lo-min-x86.elf"
            "lab/nano-lisp-jit/.build/v45-regen-lo-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-next-lisp-only.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-next-lisp-only.com"))
