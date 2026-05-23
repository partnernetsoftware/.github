; v3.5 slice 4: build-slice via nano-cc for aarch64 (NANO_CC_ARCH from build-slice arch arg;
; set NANO_BUILD_SLICE_CODEGEN=1 for nano-cc-build-slice.c).
(bootstrap
  (build-slice "lab/nano-lisp-jit/samples/nano-cc-build-slice.c"
               "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-aarch64.elf"
               "aarch64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-aarch64.elf" 43)
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-build-slice-aarch64.elf"))
