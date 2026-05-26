; Wave41 W1: runner modules 07-12 compile+run (07-abi through 12-parse).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
           "lab/nano-lisp-jit/.build/v45-rm712-mod07.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rm712-mod07.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp"
           "lab/nano-lisp-jit/.build/v45-rm712-mod08.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rm712-mod08.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/09-run.lisp"
           "lab/nano-lisp-jit/.build/v45-rm712-mod09.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rm712-mod09.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
           "lab/nano-lisp-jit/.build/v45-rm712-mod10.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rm712-mod10.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-rm712-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rm712-mod11.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-rm712-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rm712-mod12.lbin")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-compose-modules.json"))
