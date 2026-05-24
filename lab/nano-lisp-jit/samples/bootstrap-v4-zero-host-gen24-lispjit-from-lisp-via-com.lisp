; gen24: regenesis nano-jit.com + NANO_LISPJIT_FROM_LISP → full .com with lispjit-from-lisp slices.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-slice-x86.elf"
               "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-slice-aarch64.elf"
               "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-nano-jit.com")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen24-nano-jit.com"))
