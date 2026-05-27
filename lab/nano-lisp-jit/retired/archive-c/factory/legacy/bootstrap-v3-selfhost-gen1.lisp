; B-layer selfhost generation 1: genesis runner rebuilds slices + .com (orchestration in Lisp).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c" "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-slice-x86.elf" "x86_64")
  (build-slice "lab/lispjit-ir/lispjit.c" "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-slice-aarch64.elf" "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-slice-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-nano-jit.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp" "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-arithmetic.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/func-call-vm-smoke.lisp" "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-func-call.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-func-call.lbin")
  (compile "lab/nano-lisp-jit/lisp/core/func-param-vm-i64.lisp" "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-func-param-vm-i64.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-func-param-vm-i64.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-slice-x86.elf")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/gen1-nano-jit.com"))
