; Probe: batch resolve + strcmp equal strings
(module
  (import strlen "libc" "strlen" "u64(ptr)")
  (import strcmp "libc" "strcmp" "i32(ptr,ptr)")
  (import atoi "libc" "atoi" "i32(ptr)")
  (import abs "libc" "abs" "i32(i32)")
  (import getpid "libc" "getpid" "i32()")
  (const a "x")
  (const b "x")
  (main
    (resolve strlen)
    (resolve strcmp)
    (resolve atoi)
    (resolve abs)
    (resolve getpid)
    (call strlen a)
    (expect 1)
    (call strcmp a b)
    (expect 0)))
