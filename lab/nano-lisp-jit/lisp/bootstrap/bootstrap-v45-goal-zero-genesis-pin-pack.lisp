; Wave76 W3: zero-genesis-pin pack — compile x86 + ir aarch64.
(bootstrap
  (build-slice-compile "lab/nano-lisp-jit/archive/c/runner/lispjit.c"
                       "lab/nano-lisp-jit/.build/v45-zgp76-pack-x86.elf"
                       "x86_64")
  (build-slice-lisp "lab/nano-lisp-jit/lisp/core/nano-jit-slice-ir-exit-v1.lisp"
                    "lab/nano-lisp-jit/.build/v45-zgp76-pack-aarch64.elf"
                    "aarch64")
  (pack-ape "lab/nano-lisp-jit/.build/v45-zgp76-zero-pin.com"
            "lab/nano-lisp-jit/.build/v45-zgp76-pack-x86.elf"
            "lab/nano-lisp-jit/.build/v45-zgp76-pack-aarch64.elf")
  (inspect-ape "lab/nano-lisp-jit/.build/v45-zgp76-zero-pin.com")
  (file-size "lab/nano-lisp-jit/.build/v45-zgp76-zero-pin.com")
  (file-hash "lab/nano-lisp-jit/.build/v45-zgp76-zero-pin.com"))
