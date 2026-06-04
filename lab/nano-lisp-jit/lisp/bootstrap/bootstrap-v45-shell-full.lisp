; shell-full — shell-ci essentials + dual C/Rust parity + embed hash-match (~29 steps).
(bootstrap
  ; Phase 0: shell-v0 + dual-track COM proc I/O
  (compile "lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-v0.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-full-v0.lbin")
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (spawn-wait 0 "/bin/true")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-full-v0")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "compile"
    "lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
    "lab/nano-lisp-jit/.build/v45-shell-full-c.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run"
    "lab/nano-lisp-jit/.build/v45-shell-full-c.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "spawn-wait" "0" "/bin/true")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nanolisp.com" "spawn-wait" "0" "/bin/true")

  ; Phase 1: multi-step shell-script
  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-script.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-full-script.lbin")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-full-script")

  ; Phase 3: embed parity + no-arg CLI
  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-fresh.lbin")
  (hash-match "lab/nano-jit-rs/embed/shell-script.lbin"
              "lab/nano-lisp-jit/.build/v45-shell-full-fresh.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp")
  (spawn-wait 0 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp" "shell")

  ; Phase 5–6: read-line REPL + stdin addr (dual)
  (compile "lab/nano-lisp-jit/lisp/shell/shell-readline-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-readline.lbin")
  (spawn-wait 0 "/bin/sh" "-c"
    "printf 'piped-line\\n' | lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp run lab/nano-lisp-jit/.build/v45-shell-full-readline.lbin")
  (compile "lab/nano-lisp-jit/lisp/shell/shell-repl.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-repl.lbin")
  (spawn-wait 0 "/bin/sh" "-c"
    "printf '%s\\n' 'echo nanolisp-shell-full-repl' exit | lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp shell-repl")
  (compile "lab/nano-lisp-jit/lisp/shell/shell-stdin-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-stdin.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-full-stdin.lbin")

  ; Phase 7: fgets + repl-fgets
  (compile "lab/nano-lisp-jit/lisp/shell/shell-fgets-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-fgets.lbin")
  (spawn-wait 0 "/bin/sh" "-c"
    "printf 'piped-fgets-line\\n' | lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp run lab/nano-lisp-jit/.build/v45-shell-full-fgets.lbin")
  (compile "lab/nano-lisp-jit/lisp/shell/shell-repl-fgets.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-repl-fgets.lbin")
  (spawn-wait 0 "/bin/sh" "-c"
    "printf '%s\\n' 'echo nanolisp-shell-full-repl-fgets' | lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp run lab/nano-lisp-jit/.build/v45-shell-full-repl-fgets.lbin")

  ; Phase 8: APE pack + C release no-arg pin (pre-promote usage exit 2)
  (pack-ape-bare "lab/nano-lisp-jit/.build/v45-shell-full.ape"
                 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
                 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-shell-full.ape" 0)
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com"))
