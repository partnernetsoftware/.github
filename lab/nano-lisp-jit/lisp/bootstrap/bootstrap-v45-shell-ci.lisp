; shell-ci — unified shell ladder gate (Phase 0–3) as bootstrap plan only.
(bootstrap
  ; Phase 0: shell-v0 .lbin + proc I/O
  (compile "lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-ci-v0.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-ci-v0.lbin")
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (spawn-wait 0 "/bin/true")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-ci-v0")

  ; Phase 1: multi-step shell-script .lbin
  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-ci-script.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-ci-script.lbin")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-ci-script")

  ; Phase 3: embed parity + no-arg CLI + APE memfd
  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-ci-fresh.lbin")
  (hash-match "lab/nano-jit-rs/embed/shell-script.lbin"
              "lab/nano-lisp-jit/.build/v45-shell-ci-fresh.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp" "shell")
  (spawn-wait 0 "/bin/sh" "-c"
    "printf '%s\\n' 'echo nanolisp-shell-repl-echo' exit | lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp shell-repl")
  (pack-ape-bare "lab/nano-lisp-jit/.build/v45-shell-ci.ape"
                 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
                 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-shell-ci.ape" 0))
