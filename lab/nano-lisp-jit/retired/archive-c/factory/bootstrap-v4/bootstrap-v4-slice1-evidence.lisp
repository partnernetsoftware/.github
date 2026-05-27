; v4 slice-1 scoped evidence: add7 ELF + squad S1 + slice0 regression anchor.
(bootstrap
  (build-slice-lisp "lab/nano-lisp-jit/archive/c/factory/misc/nano-jit-slice-add-7.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf"
                    "aarch64")
  (file-size "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf")
  (file-size "lab/nano-lisp-jit/archive/c/factory/bootstrap-v4/bootstrap-v4-squad-signal.lisp")
  (file-size "lab/nano-lisp-jit/.build/v4-slice0.evidence"))
