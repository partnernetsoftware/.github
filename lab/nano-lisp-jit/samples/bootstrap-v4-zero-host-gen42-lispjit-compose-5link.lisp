; gen42: tier-6 compose-5link (full lispjit-modules + multi-func TU graph).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen42-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen42-slice-x86.elf" 42)
  (file-hash "lab/nano-lisp-jit/samples/lispjit-modules/02-compile.lisp")
  (file-hash "lab/nano-lisp-jit/samples/lispjit-modules/03-bootstrap-stub.lisp")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen42-slice-x86.elf"))
