; com-lisp-only bundle daily — flat tree: nano-lisp.com + bootstrap/*.lisp + lisp/** only.
(bootstrap
  (file-size "nano-lisp.com")
  (compile "lisp/core/strlen.lisp"
           ".build/v45-com-lisp-only-bundle-strlen.lbin")
  (run ".build/v45-com-lisp-only-bundle-strlen.lbin")
  (compile "lisp/core/arithmetic.lisp"
           ".build/v45-com-lisp-only-bundle-arith.lbin")
  (run ".build/v45-com-lisp-only-bundle-arith.lbin")
  (spawn-wait 0 "./nano-lisp.com" "run-bootstrap-plan"
    "bootstrap/bootstrap-v45-shell-com-only-bundle.lisp"))
