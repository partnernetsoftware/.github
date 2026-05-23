; v3.5 slice 4: nano-cc aarch64 exit42 (NANO_CC_ARCH set by runner).
(bootstrap
  (nano-cc-compile "lab/nano-lisp-jit/samples/nano-cc-hello.c"
                   "lab/nano-lisp-jit/.build/bootstrap-v35-nano-cc-aarch64.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-nano-cc-aarch64.elf"))
