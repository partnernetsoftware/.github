; shell-promote — Phase 9 C release promote ladder (plan-only; host-cc/cosmocc external).
; Ladder: (1) embed cmp archive/c vs rs; (2) host-cc factory — external
;   (nano-jit-c-shell-promote-smoke.sh); (3) spawn-wait c-noarg plan + shell-ci subset;
; (4) probe-friendly release COM no-arg exit 2; (5) COM compile/run shell-script;
; (6) cosmocc factory + v45-manifest-pin — external/manual.
(bootstrap
  ; Step 1: embed parity (promote gate)
  (file-size "lab/nano-lisp-jit/archive/c/embed/shell-script.lbin")
  (spawn-wait 0 "/bin/cmp" "-s"
    "lab/nano-lisp-jit/archive/c/embed/shell-script.lbin"
    "lab/nano-jit-rs/embed/shell-script.lbin")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-promote-embed")

  ; Step 2: host-cc factory — external (not in-plan)

  ; Step 3a: C no-arg bootstrap plan via release COM (spawn-wait ladder)
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run-bootstrap-plan"
    "lab/nano-lisp-jit/lisp/bootstrap/bootstrap-v45-shell-c-noarg.lisp")

  ; Step 3b: shell-ci subset — Rust no-arg + embed hash-match (not full shell-ci plan)
  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-promote-fresh.lbin")
  (hash-match "lab/nano-jit-rs/embed/shell-script.lbin"
              "lab/nano-lisp-jit/.build/v45-shell-promote-fresh.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp" "shell")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-promote-ci-subset")

  ; Step 4: probe-friendly release COM no-arg (pre-promote usage exit 2)
  (spawn-wait 2 "lab/nano-lisp-jit/release/nano-lisp.com")

  ; Step 5: C COM compile/run shell-script (promote path proof)
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "compile"
    "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
    "lab/nano-lisp-jit/.build/v45-shell-promote-c.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run"
    "lab/nano-lisp-jit/.build/v45-shell-promote-c.lbin")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-promote-com-script"))
