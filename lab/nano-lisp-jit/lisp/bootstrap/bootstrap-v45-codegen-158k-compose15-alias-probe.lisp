; probe: bare compose-15link profile upgrades to semantic-unified (no host-cc hybrid).
(bootstrap
  (build-slice-lisp-profile "compose-15link"
    "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
    "lab/nano-lisp-jit/.build/v45-c15-alias-probe.elf"
    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-c15-alias-probe.elf" 42))
