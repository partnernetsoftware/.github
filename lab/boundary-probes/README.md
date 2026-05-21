# boundary-probes

在 v1.5 开发期间探测 `nano-lisp-jit` 能力边界，不修改 `lispjit.c`。

```bash
bash lab/boundary-probes/run-probes.sh   # 生成 RESULTS.md
```

- `probes/*.lisp` — 探测用例（含故意失败）
- `RESULTS.md` — 自动生成结果表
- `BOUNDARY-NOTES.md` — 归纳边界与后续探测建议

反馈重要发现时可追加到 `lab/nano-lisp-jit/LAB-USAGE-FEEDBACK.md`。
