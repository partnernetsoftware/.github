; gen41b: lispjit-modules/02-compile via lispjit-mod-compile profile.
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen41b-compile-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen41b-compile-slice-x86.elf" 42)
  (file-hash "lab/nano-lisp-jit/lisp/modules/02-compile.lisp"))
