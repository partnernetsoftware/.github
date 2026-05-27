; gen13: gen12.com runs Lisp-routed build-slice (nano-jit-slice-add.lisp) — zero .c in plan.
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
               "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-lisp-route-x86.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-lisp-route-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-slice-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-lisp-route-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-slice-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen12-nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen13-nano-jit.com"))
