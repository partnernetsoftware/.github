; v3.5 L4: full gen5 plan executed by gen2 Lisp slice runner (lispjit.c slice).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-add-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-min-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-add-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-min-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-min-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-nano-jit.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-min-x86.elf")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-gen5v2-slice-min-aarch64.elf"))
