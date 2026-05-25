; Boundary: const-ptr + load-u16 (wider than u8-only probe).
(module
  (const word "Hi")
  (main
    (const-ptr word)
    (load-u16)
    (expect 26952)))
