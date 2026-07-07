; probe: compose-15link build-slice（regenesis COM · NANO_LISPJIT_FROM_LISP=1）.
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
               "lab/nano-lisp-jit/.build/v45-probe-c15-regen-x86.elf"
               "x86_64")
  (file-size "lab/nano-lisp-jit/.build/v45-probe-c15-regen-x86.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-probe-c15-regen-x86.elf" 42))
