; Read-only const string: lands in .rodata (no store ops).
(module
  (const word "Az09")
  (main
    (const-ptr word)
    (load-u8)
    (expect 65)
    (bool true)
    (not-bool)
    (expect false)))
