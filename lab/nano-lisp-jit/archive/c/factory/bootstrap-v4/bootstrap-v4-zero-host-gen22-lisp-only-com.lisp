; Final lisp-only .com build: zero .c / lispjit.c in plan (gen20.com runner).
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/lisp/core/v4-ir-table-v1.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-ir-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-add-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-lisp-only.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-min-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-ir-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-lisp-only.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen22-arithmetic.lbin"))
