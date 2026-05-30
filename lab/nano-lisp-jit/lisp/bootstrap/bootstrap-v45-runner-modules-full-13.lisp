; Wave43 W1: 13 lispjit-modules VM smoke (00–12).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod00.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod01.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod01.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/02-compile.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod02.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod02.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod03.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod03.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod04.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod05.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod05.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod06.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod06.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod07.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod07.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod08.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod08.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/09-run.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod09.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod09.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod10.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod10.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod11.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-rmf13-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rmf13-mod12.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/modules/12-parse.lisp")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-semantic-terminal.json"))
