; gen12: nano-cc build-slice (NANO_BUILD_SLICE_CODEGEN=1) + lisp aarch64 — no genesis pin.
(bootstrap
  (build-slice "lab/nano-lisp-jit/samples/nano-cc-build-slice.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-nano-cc-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-nano-cc-x86.elf" 43)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-slice-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-nano-cc-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-nano-jit.com")
  (compile "lab/nano-lisp-jit/samples/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-nano-jit.com"))
