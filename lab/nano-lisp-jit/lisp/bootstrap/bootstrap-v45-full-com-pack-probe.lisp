; B′ pack probe: full profile x86 codegen + aarch64 lisp slice → pack-ape .com (honest partial).
(bootstrap
  (build-slice-lisp-profile "full"
    "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
    "lab/nano-lisp-jit/.build/v45-full-pack-x86.elf"
    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-full-pack-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-full-pack-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-full-pack-probe.com"
            "lab/nano-lisp-jit/.build/v45-full-pack-x86.elf"
            "lab/nano-lisp-jit/.build/v45-full-pack-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-full-pack-probe.com")
  (file-size "lab/nano-lisp-jit/.build/v45-full-pack-probe.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-full-pack-probe.com"))
