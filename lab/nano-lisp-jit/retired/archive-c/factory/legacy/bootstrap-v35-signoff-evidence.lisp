; v3.5 wave-4: signoff evidence via bootstrap plan (not run.sh side effects only).
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v35-signoff-aarch64-add.elf"
                    "aarch64")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-v35-signoff-aarch64-add.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v35-signoff-aarch64-add.elf")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-min.lisp"
                    "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-signoff-wave4-min-x86.elf"
                    "x86_64")
  (run-expect-exit "lab/nano-lisp-jit/.build/nano-jit/selfhost/v35-signoff-wave4-min-x86.elf" 42))
