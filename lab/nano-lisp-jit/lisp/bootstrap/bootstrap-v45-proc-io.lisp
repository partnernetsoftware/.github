; Wave90 W1: proc-io — read-file + spawn-wait(argv) bootstrap 原语 dogfooding
(bootstrap
  (read-file "lab/nano-lisp-jit/release/manifest.txt")
  (read-file "lab/nano-lisp-jit/.build/v45-entry.evidence")
  (spawn-wait 0 "/bin/true")
  (spawn-wait 7 "/bin/sh" "-c" "exit 7")
  (emit-elf64-exit "lab/nano-lisp-jit/.build/v45-w90-proc-exit42.elf" 42)
  (run-expect-exit "lab/nano-lisp-jit/.build/v45-w90-proc-exit42.elf" 42))
