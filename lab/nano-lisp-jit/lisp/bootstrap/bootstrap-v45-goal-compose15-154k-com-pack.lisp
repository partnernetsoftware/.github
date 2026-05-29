; Wave87: compose15 bulk-scale 154KB x86 + ir-exit aarch64 → pack COM.
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-w87-c15-154k-x86.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-w87-c15-154k-x86.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w87-c15-154k-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-w87-c15-154k-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-w87-compose15-154k.com"
            "lab/nano-lisp-jit/.build/v45-w87-c15-154k-x86.elf"
            "lab/nano-lisp-jit/.build/v45-w87-c15-154k-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-w87-compose15-154k.com")
  (file-size "lab/nano-lisp-jit/.build/v45-w87-compose15-154k.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-w87-compose15-154k.com"))
