; codegen-158k flat bundle — nano-lisp.com + bootstrap/ + lisp/ at one root.
(bootstrap
  (lisp-root ".")
  (file-size "nano-lisp.com")
  (build-slice-lisp-profile "compose-15link-semantic-unified"
    "lisp/lispjit.c"
    ".build/v45-codegen-158k-bundle.elf"
    "x86_64")
  (file-size ".build/v45-codegen-158k-bundle.elf")
  (run-expect-exit ".build/v45-codegen-158k-bundle.elf" 42))
