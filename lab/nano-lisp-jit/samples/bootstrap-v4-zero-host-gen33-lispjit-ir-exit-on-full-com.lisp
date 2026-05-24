; gen33: gen30 full .com — ir-exit-v1 profile (tier-2 named proxy).
(bootstrap
  (build-slice "lab/lispjit-ir/lispjit.c"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen33-slice-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen33-slice-x86.elf" 42)
  (compile "lab/nano-lisp-jit/samples/func-call-vm-smoke.lisp"
           "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen33-func-call.lbin")
  (run "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen33-func-call.lbin")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen33-slice-x86.elf"))
