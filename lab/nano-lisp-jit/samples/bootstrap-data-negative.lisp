(bootstrap
  (link-expect-exit 4 "lab/nano-lisp-jit/.build/data-bad-reloc-type-fail" "nano_main"
    "lab/nano-lisp-jit/.build/data-bad-reloc-type.o")
  (link-expect-exit 4 "lab/nano-lisp-jit/.build/data-bad-reloc-sym-fail" "nano_main"
    "lab/nano-lisp-jit/.build/data-bad-reloc-sym.o")
  (link-expect-exit 4 "lab/nano-lisp-jit/.build/data-bad-symbol-shndx-fail" "nano_main"
    "lab/nano-lisp-jit/.build/data-bad-symbol-shndx.o"))
