; v4 slice-2 scoped evidence: squad S2 state + gen5-via-gen2 anchor + slice-1 add7.
(bootstrap
  (file-size "lab/nano-lisp-jit/.squad/state-v4.db")
  (file-hash "lab/nano-lisp-jit/.squad/state-v4.json")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v4-squad-s2-state.lisp")
  (file-size "lab/nano-lisp-jit/samples/bootstrap-v4-gen5-via-gen2-anchor.lisp")
  (build-slice-lisp "lab/nano-lisp-jit/samples/nano-jit-slice-add-7.lisp"
                    "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf"
                    "aarch64")
  (file-hash "lab/nano-lisp-jit/.build/bootstrap-v4-slice1-add7.elf"))
