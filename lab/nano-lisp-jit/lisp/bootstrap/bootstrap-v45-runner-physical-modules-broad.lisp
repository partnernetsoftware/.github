; Wave39 W1: runner physical — broader lispjit-modules compile/run matrix (00–06, expands wave34 00/04/12 subset).
(bootstrap
  (compile "lab/nano-lisp-jit/lisp/modules/00-runtime-core.lisp"
           "lab/nano-lisp-jit/.build/v45-rpm-mod00.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpm-mod00.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/01-runtime-extra.lisp"
           "lab/nano-lisp-jit/.build/v45-rpm-mod01.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpm-mod01.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/02-compile.lisp"
           "lab/nano-lisp-jit/.build/v45-rpm-mod02.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpm-mod02.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/03-bootstrap-stub.lisp"
           "lab/nano-lisp-jit/.build/v45-rpm-mod03.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpm-mod03.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/04-vm.lisp"
           "lab/nano-lisp-jit/.build/v45-rpm-mod04.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpm-mod04.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/05-aot.lisp"
           "lab/nano-lisp-jit/.build/v45-rpm-mod05.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpm-mod05.lbin")
  (compile "lab/nano-lisp-jit/lisp/modules/06-elf.lisp"
           "lab/nano-lisp-jit/.build/v45-rpm-mod06.lbin")
  (run "lab/nano-lisp-jit/.build/v45-rpm-mod06.lbin")
  (file-hash "lab/nano-lisp-jit/v4.5/mindmap-frontier-v45-runner-physical.json"))
