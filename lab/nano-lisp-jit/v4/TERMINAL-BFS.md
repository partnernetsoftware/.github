# 终局广度优先（BFS）· 对齐 nano-jit.com 主线

**北极星**（`ROADMAP.md` §7）：universal loader + 各架构 **payload 加载** + JIT/AOT（`.lisp`/`.lbin`）→ 组装 **`.com`** → self-pack 自举。

**与 waveNNN 扩波的区别**：波次铺 **Plan 回归网**；本 BFS 铺 **终局六轨骨架**，每轨可并行 cc 填肉。

## 六轨（广度一层）

| 轨 | ID | 扩散产物 | 细节（≤4 cc） |
|----|-----|----------|----------------|
| Loader | **LDR** | `bootstrap-v4-terminal-ldr-diffusion.lisp` | `run-ape.payload.load` / `payload.arch` in `nano_ape.c` |
| Pack | **PACK** | `bootstrap-v4-terminal-pack-diffusion.lisp` | 复用 `pack-ape` 双架构 slice |
| JIT | **JIT** | `bootstrap-v4-terminal-jit-diffusion.lisp` | `(compile … arithmetic.lisp → .lbin)` |
| AOT | **AOT** | `bootstrap-v4-terminal-aot-diffusion.lisp` | `(build-slice-lisp … aarch64)` |
| .com 组装 | **COM** | `bootstrap-v4-terminal-com-assembly.lisp` | LDR+PACK+JIT 链式 plan |
| 自举 | **BOOT** | `bootstrap-v4-terminal-boot-diffusion.lisp` | 锚定 gen1/selfhost + `nano-jit.com` hash |

## 每回合协议（挂在 MINDMAP 活图下）

```text
0. python3 tools/mindmap-dp.py ready     # DP：从 MINDMAP/frontier 取就绪节点
1. 扩散  python3 tools/gen-terminal-bfs.py   # 或按节点写单轨 plan（非 wave 批）
2. 并发  bash tools/v4-terminal-bfs-cc.sh    # ≤4 × cc-huoshan1-ds4pro
3. 收敛  export NANO_SLICE_COMPILER=native && bash run.sh
4. 回写  MINDMAP.md + mindmap-frontier.json（done/ready/blocked）
5. 评估  EVAL.md + PROGRESS 六维
```

证据文件：`.build/v4-terminal-bfs.evidence`
