; v3 slice 4b gen3: gen2 runner builds codegen slices (lisp + nano-cc) alongside full cc slices.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-slice-lisp-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-slice-lisp-x86.elf" 42)
  (build-slice "lab/nano-lisp-jit/archive/fixtures/nano-cc-hello.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-slice-nano-cc-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-slice-nano-cc-x86.elf" 42)
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-slice-x86.elf"
               "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-slice-aarch64.elf"
               "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-slice-aarch64.elf")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen3-arithmetic.lbin"))
