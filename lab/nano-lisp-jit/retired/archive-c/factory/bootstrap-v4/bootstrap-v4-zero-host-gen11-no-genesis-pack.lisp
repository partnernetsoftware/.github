; gen11: dual-arch Lisp slices only — pack-ape with NO genesis/ paths.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-slice-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-slice-min-x86.elf" 42)
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-slice-min-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-slice-add-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-slice-add-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-slice-min-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-slice-min-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen11-nano-jit.com"))
