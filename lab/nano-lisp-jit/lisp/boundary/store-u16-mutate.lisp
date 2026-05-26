; Boundary: const-ptr + store-u16 + load-u16 (mutate rodata slot).
(module
  (const tag "xy")
  (main
    (const-ptr tag)
    (store-u16 17218)
    (load-u16)
    (expect 17218)))
