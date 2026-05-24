; v4 slice-0 scoped evidence: aarch64 scout + squad S0–S3 plan markers.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-aarch64-add-scout.elf"
                    "aarch64")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-v4-aarch64-add-scout.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-aarch64-add-scout.elf")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v4-squad-assess.lisp")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v4-squad-dispatch.lisp")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v4-squad-run-loop-once.lisp"))
