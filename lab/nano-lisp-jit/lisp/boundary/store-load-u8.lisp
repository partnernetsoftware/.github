; Boundary: const-ptr + load-u8 (rodata path).
(module
  (const byte "A")
  (main
    (const-ptr byte)
    (load-u8)
    (expect 65)))
