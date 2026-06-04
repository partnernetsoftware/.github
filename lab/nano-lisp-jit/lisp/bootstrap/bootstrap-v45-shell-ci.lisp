; shell-ci — unified shell ladder gate (Phase 0–7) as bootstrap plan only.
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

  ; Phase 5: VM read-line REPL
  (compile "lab/nano-lisp-jit/lisp/shell/shell-readline-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-ci-readline.lbin")
  (spawn-wait 0 "/bin/sh" "-c"
    "printf 'piped-line\\n' | lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp run lab/nano-lisp-jit/.build/v45-shell-ci-readline.lbin")
  (compile "lab/nano-lisp-jit/lisp/shell/shell-repl.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-ci-repl.lbin")
  (spawn-wait 0 "/bin/sh" "-c"
    "printf '%s\\n' 'echo nanolisp-shell-ci-repl' exit | lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp shell-repl")

  ; Phase 7: libc fgets smoke + repl-fgets (piped stdin)
  (compile "lab/nano-lisp-jit/lisp/shell/shell-fgets-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-ci-fgets-smoke.lbin")
  (spawn-wait 0 "/bin/sh" "-c"
    "printf 'piped-fgets-line\\n' | lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp run lab/nano-lisp-jit/.build/v45-shell-ci-fgets-smoke.lbin")
  (compile "lab/nano-lisp-jit/lisp/shell/shell-repl-fgets.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-ci-repl-fgets.lbin")
  (spawn-wait 0 "/bin/sh" "-c"
    "printf '%s\\n' 'echo nanolisp-shell-ci-repl-fgets' | lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp run lab/nano-lisp-jit/.build/v45-shell-ci-repl-fgets.lbin")

  ; Phase 7b: C embed parity + release COM (pre-promote gap) + shell-script via COM
  (file-size "lab/nano-lisp-jit/archive/c/embed/shell-script.lbin")
  (spawn-wait 0 "/bin/cmp" "-s"
    "lab/nano-lisp-jit/archive/c/embed/shell-script.lbin"
    "lab/nano-jit-rs/embed/shell-script.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "spawn-wait" "0" "/bin/true")
  ; C release no-arg: nano-jit-rs-shell-ci-smoke.sh + nanolisp-c-release-shell-probe.sh
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "compile"
    "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
    "lab/nano-lisp-jit/.build/v45-shell-ci-c.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run"
    "lab/nano-lisp-jit/.build/v45-shell-ci-c.lbin")

  (pack-ape-bare "lab/nano-lisp-jit/.build/v45-shell-ci.ape"
                 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp"
                 "lab/nano-lisp-jit/.build/nano-jit-rs/nanolisp.aarch64")
  (run-ape-expect-exit "lab/nano-lisp-jit/.build/v45-shell-ci.ape" 0))
