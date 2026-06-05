; shell-com-only bundle — flat tree: nano-lisp.com + bootstrap/*.lisp + lisp/** only.
(bootstrap
  (compile "lisp/shell/shell-v0-system.lisp"
           ".build/v45-shell-com-only-bundle-v0.lbin")
  (run ".build/v45-shell-com-only-bundle-v0.lbin")

  (compile "lisp/shell/shell-script.lisp"
           ".build/v45-shell-com-only-bundle-script.lbin")
  (run ".build/v45-shell-com-only-bundle-script.lbin")

  (compile "lisp/shell/shell-script.lisp"
           ".build/v45-shell-com-only-bundle-script2.lbin")
  (compare ".build/v45-shell-com-only-bundle-script.lbin"
           ".build/v45-shell-com-only-bundle-script2.lbin")

  (spawn-wait 0 "./nano-lisp.com")

  (spawn-wait 0 "./nano-lisp.com" "compile"
    "lisp/shell/shell-script.lisp"
    ".build/v45-shell-com-only-bundle-com.lbin")
  (spawn-wait 0 "./nano-lisp.com" "run"
    ".build/v45-shell-com-only-bundle-com.lbin")

  (compile "lisp/shell/shell-fgets-smoke.lisp"
           ".build/v45-shell-com-only-bundle-fgets.lbin")
  (run-stdin "piped-fgets-line\n"
    ".build/v45-shell-com-only-bundle-fgets.lbin"))
