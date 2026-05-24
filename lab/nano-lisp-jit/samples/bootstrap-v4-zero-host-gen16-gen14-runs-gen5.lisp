; gen16: gen15.com re-runs lisp dual-arch pack (nested selfhost).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen16-slice-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen16-slice-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen16-slice-min-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen16-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen16-slice-min-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen16-slice-min-aarch64.elf")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen15-nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen16-nano-jit.com"))
