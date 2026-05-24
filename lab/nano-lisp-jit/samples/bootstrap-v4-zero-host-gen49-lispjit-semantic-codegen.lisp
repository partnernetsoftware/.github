; gen49: tier-8 semantic-codegen — 9 TU pure Lisp link (no genesis pin).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen49-semantic-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen49-semantic-slice-x86.elf" 42)
  (file-size "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen49-semantic-slice-x86.elf")
  (file-hash "lab/nano-lisp-jit/samples/lispjit-modules/04-vm.lisp")
  (file-hash "lab/nano-lisp-jit/samples/lispjit-modules/05-aot.lisp")
  (file-hash "lab/nano-lisp-jit/samples/lispjit-modules/06-elf.lisp"))
