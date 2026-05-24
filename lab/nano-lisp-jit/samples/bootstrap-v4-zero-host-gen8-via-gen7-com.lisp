; gen8: gen7.com → dual-arch lisp-only pack (no genesis), like gen5.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-slice-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-slice-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-slice-min-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-slice-min-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-slice-min-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-nano-jit.com")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen7-nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen8-nano-jit.com"))
