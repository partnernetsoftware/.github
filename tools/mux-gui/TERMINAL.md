# 浏览器终端方案调研

xterm.js 是当前最稳妥的选择。ANSI/VT 兼容性成熟，生态里已有 FitAddon、WebLinksAddon、SearchAddon 等常用能力，tmux/rmux pane 快照和增量流这类场景基本不需要额外终端协议适配。渲染上它默认 DOM/Canvas，另有 WebGL addon，可按性能需求启用；作为普通 Web 组件嵌入浏览器，依赖可通过 esm.sh 加载，不要求引入构建链。

hterm 来自 Chromium/ChromeOS，ANSI 兼容性也强，文本终端稳定，但模块化和现代前端嵌入体验不如 xterm.js；它更像完整终端应用组件，样式与输入管线定制成本偏高，社区可见活跃度也弱于 xterm.js。

wezterm-wasm 的终端内核能力强，但浏览器嵌入形态不是主流发布目标，WASM 体积、加载、字体/渲染整合复杂度较高，通常需要更重的构建与打包流程。kitty wasm/相关实验方案同理，协议能力先进但 Web UI 生态不成熟，零构建接入风险高。

确定推荐：使用 xterm.js。理由是它在 ANSI 兼容性、Canvas/WebGL 渲染、维护活跃度、零构建 CDN 使用之间综合最优，最适合 mux GUI 骨架快速落地。