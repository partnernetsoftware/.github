; S16 codegen: IR fixed words listed in plan-side v4-ir-words-v1.txt (not .c source).
(bootstrap
  (file-size "lab/nano-lisp-jit/samples/v4-ir-words-v1.txt")
  (file-hash "lab/nano-lisp-jit/samples/v4-ir-words-v1.txt")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-19.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice16-add19.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice16-add19.elf"))
