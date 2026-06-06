; v4.5 unified daily flat bundle — nano-lisp.com + bootstrap/ + lisp/ at one root.
(bootstrap
  (lisp-root ".")
  (file-size "nano-lisp.com")
  (compile "lisp/core/strlen.lisp"
           ".build/v45-unified-bundle-strlen.lbin")
  (run ".build/v45-unified-bundle-strlen.lbin")
  (compile "lisp/core/arithmetic.lisp"
           ".build/v45-unified-bundle-arith.lbin")
  (run ".build/v45-unified-bundle-arith.lbin")
  (spawn-wait 0 "./nano-lisp.com" "run-bootstrap-plan"
    "bootstrap/bootstrap-v45-shell-com-only-bundle.lisp")
  (build-slice-lisp-profile "compose-15link"
    "lisp/lispjit.c"
    ".build/v45-unified-bundle-codegen.elf"
    "x86_64")
  (file-size ".build/v45-unified-bundle-codegen.elf")
  (run-expect-exit ".build/v45-unified-bundle-codegen.elf" 42)
  (build-slice-lisp "lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    ".build/v45-unified-bundle-aarch64.elf"
                    "aarch64")
  (extract-ape-slice "nano-lisp.com"
                     ".build/v45-unified-bundle-x86-pack.elf"
                     "x86_64")
  (pack-ape ".build/v45-unified-bundle-regenesis.com"
            ".build/v45-unified-bundle-x86-pack.elf"
            ".build/v45-unified-bundle-aarch64.elf")
  (file-size ".build/v45-unified-bundle-regenesis.com"))
