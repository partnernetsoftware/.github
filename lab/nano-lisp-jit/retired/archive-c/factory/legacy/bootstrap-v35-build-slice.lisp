; v3.5 slice 3: build-slice via nano-cc (set NANO_BUILD_SLICE_CODEGEN=1 for nano-cc-build-slice.c).
(bootstrap
  (build-slice "lab/nano-lisp-jit/archive/fixtures/nano-cc-build-slice.c"
               "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice.elf" 43)
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice.elf"))
