; v3.5 slice 0: nano-cc CLI + bootstrap DSL (zero host cc).
(bootstrap
  (nano-cc-compile "lab/nano-lisp-jit/archive/fixtures/nano-cc-hello.c"
                   "lab/nano-lisp-jit/.build/bootstrap-v35-nano-cc-hello.elf")
  (run-expect-exit "lab/nano-lisp-jit/.build/bootstrap-v35-nano-cc-hello.elf" 42)
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-nano-cc-hello.elf"))
