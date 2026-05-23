; v4 slice-12: plan-side add-exit IR (mirrors v4-aarch64-add-exit-ops.manifest).
(add-exit-ops
  (version 1)
  (profile add-exit-v1)
  (ops movz_x0 movz_x1 add_x0_x1 movz_x8 svc0)
  (encodes
    (encode movz_x0 (imm a) (base #xd2800000) (mask #xffff) (shift 5) (rd 0))
    (encode movz_x1 (imm b) (base #xd2800000) (mask #xffff) (shift 5) (rd 1))
    (encode add_x0_x1 (fixed #x8b010000))
    (encode movz_x8 (fixed #xd2800ba8))
    (encode svc0 (fixed #xd4000001))))
