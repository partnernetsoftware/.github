# Wave104 — APE 6 面全表探针（Windows os_id=3）

**签收**：`v45.goal.ape_six_face_probe_milestone=1`

| 槽 | 交付 |
|----|------|
| W1 | `gen-ape-six-face-probe.py` → 6-row APE v2 bare |
| W2 | `inspect-ape` os_id=1/2/3 全表 · size=0 cross-os placeholder |
| W3 | 复跑 macOS audit + 6-face expand gate |
| W4 | journal round 33 |

**诚实分层**（禁止混称 6/6 runtime DONE）：

| 行 | OS | os_id | size | runtime |
|----|-----|-------|------|---------|
| 0–1 | Linux | 1 | ELF | ✅ 2/6 |
| 2–3 | macOS | 2 | 0 | 探针 |
| 4–5 | Windows | 3 | 0 | 探针 |

```bash
bash lab/nano-lisp-jit/retired/scripts/v45-wave104-ape-six-face-probe-converge.sh
```

**下一刀**：真实 Mach-O/PE slice · build_nano_jit 工厂 lisp-only 路径
