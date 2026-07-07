; B′ regenesis probe: full profile x86 codegen + aarch64 lisp slice → pack-ape → spawn child plan.
(bootstrap
  (build-slice-lisp-profile "full"
    "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
    "lab/nano-lisp-jit/.build/v45-full-regenesis-x86.elf"
    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-full-regenesis-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-full-regenesis-aarch64.elf"
                    "aarch64")
  (extract-ape-slice "lab/nano-lisp-jit/release/nano-lisp.com"
                     "lab/nano-lisp-jit/.build/v45-full-regenesis-x86-pack.elf"
                     "x86_64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-full-regenesis.com"
            "lab/nano-lisp-jit/.build/v45-full-regenesis-x86-pack.elf"
            "lab/nano-lisp-jit/.build/v45-full-regenesis-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-full-regenesis.com")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/v45-full-regenesis.com" "run-bootstrap-plan"
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-full-com-regenesis-child.lisp")
  (file-size "lab/nano-lisp-jit/.build/v45-full-regenesis.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-full-regenesis.com"))
