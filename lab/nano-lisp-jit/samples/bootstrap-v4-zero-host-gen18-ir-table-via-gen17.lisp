; gen18: gen17.com emits IR-table slice + repack (Lisp codegen path, zero .c in plan).
(bootstrap
  (ir-table-lisp "lab/nano-lisp-jit/samples/v4-ir-table-v1.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen18-ir-exit-aarch64.elf"
                    "aarch64")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen18-slice-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen18-slice-min-x86.elf" 42)
  (pack-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen18-nano-jit.com"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen18-slice-min-x86.elf"
            "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen18-ir-exit-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen18-nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen17-nano-jit.com")
  (file-hash "lab/nano-lisp-jit/.build/nano-jit/selfhost/zero-host-gen18-nano-jit.com"))
