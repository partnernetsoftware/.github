; v4.5 S7: all 13 lispjit-modules VM smoke (one plan, no per-module waves).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod00.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod01.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod01.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/02-compile.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod02.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod02.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod03.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod03.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod04.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod05.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod05.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod06.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod06.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/07-abi.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod07.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod07.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/08-manifest.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod08.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod08.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/09-run.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod09.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod09.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/10-pack.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod10.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod10.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/11-ape.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod11.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod11.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"
           "lab/nano-lisp-jit/.build/v45-sh-full-mod12.lbin")
  (run "lab/nano-lisp-jit/.build/v45-sh-full-mod12.lbin")
  (file-hash "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp")
  (file-hash "lab/nano-lisp-jit/lisp/modules/12-parse.lisp"))
