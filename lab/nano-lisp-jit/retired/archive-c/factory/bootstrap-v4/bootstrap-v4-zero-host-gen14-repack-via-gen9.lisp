; gen14: repack gen12 nano-cc + gen13 lisp slices — plan has NO lispjit.c / genesis paths.
(bootstrap
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen14-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-nano-cc-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen14-nano-jit.com")
  (compile "lab/nano-lisp-jit/lisp/core/arithmetic.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen14-arithmetic.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen14-arithmetic.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen14-nano-jit.com"))
