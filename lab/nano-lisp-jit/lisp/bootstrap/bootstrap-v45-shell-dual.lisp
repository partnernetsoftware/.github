; shell-dual — Rust + C COM both compile/run shell-v0 (dual-track parity).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-dual-rs.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-dual-rs.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "compile"
    "lab/nano-lisp-jit/lisp/shell/shell-v0-system.lisp"
    "lab/nano-lisp-jit/.build/v45-shell-dual-c.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "run"
    "lab/nano-lisp-jit/.build/v45-shell-dual-c.lbin")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nano-lisp.com" "spawn-wait" "0" "/bin/true")
  (spawn-wait 0 "lab/nano-lisp-jit/release/nanolisp.com" "spawn-wait" "0" "/bin/true")
  (compile "lab/nano-lisp-jit/lisp/shell/shell-stdin-smoke.lisp"
           "lab/nano-lisp-jit/.build/v45-shell-stdin-smoke.lbin")
  (run "lab/nano-lisp-jit/.build/v45-shell-stdin-smoke.lbin"))
