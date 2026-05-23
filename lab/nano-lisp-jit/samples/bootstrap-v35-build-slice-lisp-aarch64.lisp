; v3.5 L3: build-slice-lisp aarch64 exit emit (nano-jit-slice-min.lisp, zero host cross-gcc).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-lisp-aarch64.elf"
                    "aarch64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-lisp-aarch64.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-lisp-aarch64.elf"))
