; v4.5 TERMINAL daily flat bundle.
(bootstrap
  (lisp-root ".")
  (file-size "nano-lisp.com")
  (compile "lisp/core/strlen.lisp" ".build/v45-terminal-bundle-strlen.lbin")
  (run ".build/v45-terminal-bundle-strlen.lbin")
  (compile "lisp/core/arithmetic.lisp" ".build/v45-terminal-bundle-arith.lbin")
  (run ".build/v45-terminal-bundle-arith.lbin")
  (spawn-wait 0 "./nano-lisp.com" "run-bootstrap-plan"
    "bootstrap/bootstrap-v45-shell-com-only-bundle.lisp")
  (build-slice-lisp-profile "compose-15link"
    "lisp/lispjit.c" ".build/v45-terminal-bundle-158k.elf" "x86_64")
  (run-expect-exit ".build/v45-terminal-bundle-158k.elf" 42)
  (extract-ape-slice "nano-lisp.com" ".build/v45-terminal-bundle-x86.elf" "x86_64")
  (extract-ape-slice "nano-lisp.com" ".build/v45-terminal-bundle-a64.elf" "aarch64")
  (pack-ape ".build/v45-terminal-bundle-regenesis.com"
            ".build/v45-terminal-bundle-x86.elf"
            ".build/v45-terminal-bundle-a64.elf")
  (file-size ".build/v45-terminal-bundle-regenesis.com"))
