; shell-full-c — C COM subset mirroring shell-full (no hash-match/pack-ape/Rust piped).
(bootstrap
  ; Phase 0: shell-v0 + dual-track COM proc I/O
  (compile "lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-c-v0.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-full-c-v0.lbin")
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (spawn-wait 0 "/bin/true")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-full-c-v0")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "compile"
    "lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
    "lab/nano-lisp-jit/.build/v45-shell-full-c-com-v0.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run"
    "lab/nano-lisp-jit/.build/v45-shell-full-c-com-v0.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "spawn-wait" "0" "/bin/true")

  ; Phase 1: multi-step shell-script
  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-c-script.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-full-c-script.lbin")
  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-full-c-script")

  ; Phase 3: deterministic compile + C COM no-arg rodata
  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-c-fresh.lbin")
  (compile "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-c-fresh2.lbin")
  (compare "lab/nano-lisp-jit/.build/v45-shell-full-c-fresh.lbin"
           "lab/nano-lisp-jit/.build/v45-shell-full-c-fresh2.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "compile"
    "lab/nano-lisp-jit/lisp/shell/shell-script.lisp"
    "lab/nano-lisp-jit/.build/v45-shell-full-c-com-script.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run"
    "lab/nano-lisp-jit/.build/v45-shell-full-c-com-script.lbin")

  ; Phase 7: fgets smoke — compile in-plan, piped run via run-stdin (no /bin/sh)
  (compile "lab/nano-lisp-jit/lisp/shell/shell-fgets-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-full-c-fgets.lbin")
  (run-stdin "piped-fgets-line\n"
    "lab/nano-lisp-jit/.build/v45-shell-full-c-fgets.lbin")

  (spawn-wait 0 "/bin/sh" "-c" "echo nanolisp-shell-full-c-ok"))
