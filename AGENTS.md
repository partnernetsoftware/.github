# AGENTS.md

## Cursor Cloud specific instructions

### Codebase overview

Multi-product personal codebase:
- **Jekyll Blog** (root) — GitHub Pages site, `bundle exec jekyll serve` on port 4000
- **Python MCP Services** (`products/`) — MCP stdio servers (`ctx.py`, `ai.py`, `hub.py`, `ctx_store.py`)
- **CosmoRun** (`cosmorun/`) — C code execution via TinyCC + Cosmopolitan (needs `third_party/cosmocc/` which is gitignored)
- **TUI** (`tools/tui.ts`) — Bun-based tmux dashboard

### Running services

| Service | Command | Notes |
|---|---|---|
| Jekyll blog | `cd /workspace && bundle exec jekyll serve --host 0.0.0.0 --port 4000` | Requires `bundle install` with local path first |
| MCP ai.py | `python3 /workspace/products/ai.py server` | Stdio JSON-RPC; pipe JSON to stdin |
| MCP ctx.py | `python3 /workspace/products/ctx.py server` | Has singleton check that may kill its own process via ps grep; test via direct Python import instead |
| MCP hub.py | `HUB_TOKEN=... python3 /workspace/products/hub.py server` | Self-hosted login/config vault; bootstrap: `HUB_BOOTSTRAP_KEY=... python3 products/hub.py bootstrap`; data in `HUB_DATA_DIR` or `~/.hub` |
| TUI | `bun run /workspace/tools/tui.ts status` | Needs `export PATH="$HOME/.bun/bin:$PATH"` |

### Gotchas

- **webrick**: Jekyll 3.x on Ruby 3+ requires `gem "webrick"` in Gemfile (removed from stdlib in Ruby 3.0).
- **Bundle path**: Use `bundle config set --local path 'vendor/bundle'` to avoid system gem permission issues.
- **ctx.py singleton**: The `check_singleton()` in `ctx.py` greps `ps aux` for `ctx.py server` and may kill its own process. For testing, instantiate `MCPServer` directly in Python.
- **CosmoRun**: Requires `third_party/cosmocc/` (Cosmopolitan cross-compiler) which is in `.gitignore`. Use the dev container (`Dockerfile.dev`) instead — cosmocc is at `/opt/cosmocc/bin/`.
- **Bun**: Installed to `~/.bun/bin/bun`; add to PATH before use.
- **Python packages**: `duckdb` and `pyyaml` are required by `products/ctx_store.py` and `products/ctx.mgr.py`.

### Dev container (Docker)

`Dockerfile.dev` provides a unified dev environment with all native toolchains:

```bash
# Interactive shell with all tools
sudo docker compose -f docker-compose.dev.yml run --rm dev bash

# One-off compile
sudo docker compose -f docker-compose.dev.yml run --rm dev cosmocc hello.c -o hello.exe
```

| Toolchain | Version | Path in container |
|---|---|---|
| cosmocc (Cosmopolitan) | 4.0.2 | `/opt/cosmocc/bin/` |
| Zig | 0.16.0 | `/opt/zig/` |
| Rust (rustc + cargo) | 1.95.0 | `/root/.cargo/bin/` |
| Bun | 1.3.14 | `/root/.bun/bin/` |

The workspace is mounted at `/workspace` so edits are reflected immediately. CosmoRun build scripts expect cosmocc at `third_party/cosmocc/bin/`; inside the container, use a symlink: `ln -s /opt/cosmocc third_party/cosmocc`.
