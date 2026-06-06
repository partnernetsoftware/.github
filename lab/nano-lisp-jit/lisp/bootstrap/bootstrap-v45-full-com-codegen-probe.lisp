; B′ probe: full profile → compose15 semantic-unified pure codegen (154KB slice, not 863KB COM).
(bootstrap
  (build-slice-lisp-profile "full"
    "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
    "lab/nano-lisp-jit/.build/v45-full-com-codegen-probe.elf"
    "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-full-com-codegen-probe.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-full-com-codegen-probe.elf" 42))
