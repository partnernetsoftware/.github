; B-layer selfhost generation 2: gen1 slice runner rebuilds gen2 (closed loop).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c" "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-slice-x86.elf" "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c" "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-slice-aarch64.elf" "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-nano-jit.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp" "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-slice-x86.elf")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen2-nano-jit.com"))
