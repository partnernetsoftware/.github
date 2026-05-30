; v3.5 slice 5: gen2 runner builds gen3 via build-slice-lisp + nano-cc samples;
; pack-ape uses genesis pin directly (no lispjit.c build-slice).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen3-slice-lisp-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen3-slice-lisp-x86.elf" 42)
  (build-slice "lab/nano-lisp-jit/archive/fixtures/nano-cc-hello.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen3-slice-nano-cc-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen3-slice-nano-cc-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen3-nano-jit.com"
            "lab/nano-lisp-jit/genesis/nano-jit.x86_64"
            "lab/nano-lisp-jit/genesis/nano-jit.aarch64")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen3-nano-jit.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen3-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen3-arithmetic.lbin"))
