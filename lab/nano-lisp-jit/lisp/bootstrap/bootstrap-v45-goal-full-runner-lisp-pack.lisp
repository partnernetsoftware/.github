; Wave75 W2: full runner pack — genesis-pin x86 + ir-exit aarch64.
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-fr75-pack-x86.elf"
               "x86_64")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-fr75-pack-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-fr75-full-runner.com"
            "lab/nano-lisp-jit/.build/v45-fr75-pack-x86.elf"
            "lab/nano-lisp-jit/.build/v45-fr75-pack-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-fr75-full-runner.com")
  (file-size "lab/nano-lisp-jit/.build/v45-fr75-full-runner.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-fr75-full-runner.com"))
