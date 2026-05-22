; v3 slice 4b: Lisp codegen + nano-cc C-subset (zero host cc for these artifacts).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v3-codegen-lisp.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v3-codegen-lisp.elf" 42)
  (build-slice "lab/nano-lisp-jit/samples/nano-cc-hello.c"
               "lab/nano-lisp-jit/.build/bootstrap-v3-codegen-nano-cc.elf"
               "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v3-codegen-nano-cc.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v3-codegen-lisp.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v3-codegen-nano-cc.elf"))
