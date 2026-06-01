# APE 6 面规划（Wave71 W4 · 扩散 SSOT）

| arch_id | os_id | OS | ISA | release COM | 目标 |
|---------|-------|-----|-----|-------------|------|
| 1 | 1 | Linux | x86_64 | ✅ 154KB | 保持 |
| 2 | 1 | Linux | aarch64 | ✅ 154KB | 保持 |
| 1 | 2 | macOS | x86_64 | 🔬 probe | os_id=2 · size=0 placeholder（Wave103） |
| 2 | 2 | macOS | aarch64 | 🔬 probe | 同上 |
| 1 | 3 | Windows | x86_64 | 🔬 probe | os_id=3 · size=0 placeholder（Wave104） |
| 2 | 3 | Windows | aarch64 | 🔬 probe | 同上 |

**当前**：release COM **Linux 2/2 runtime** · 6-row probe 表 **6/6 inspect** · runtime **2/6**  
**Wave104**：全表 os_id 1/2/3 · `ape_six_face_probe_milestone=1`  
**下一刀**：真实 Mach-O/PE slice · build_nano_jit 工厂 lisp-only 路径
