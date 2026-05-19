# AGENTS.md

## Cursor Cloud specific instructions

### Codebase overview

Multi-product personal codebase:
- **Jekyll Blog** (root) — GitHub Pages site, `bundle exec jekyll serve` on port 4000
- **Python MCP Services** (`products/`) — MCP stdio servers (`ctx.py`, `ai.py`, `ctx_store.py`)
- **CosmoRun** (`cosmorun/`) — C code execution via TinyCC + Cosmopolitan (needs `third_party/cosmocc/` which is gitignored)
- **TUI** (`tools/tui.ts`) — Bun-based tmux dashboard

### Running services

| Service | Command | Notes |
|---|---|---|
| Jekyll blog | `cd /workspace && bundle exec jekyll serve --host 0.0.0.0 --port 4000` | Requires `bundle install` with local path first |
| MCP ai.py | `python3 /workspace/products/ai.py server` | Stdio JSON-RPC; pipe JSON to stdin |
| MCP ctx.py | `python3 /workspace/products/ctx.py server` | Has singleton check that may kill its own process via ps grep; test via direct Python import instead |
| TUI | `bun run /workspace/tools/tui.ts status` | Needs `export PATH="$HOME/.bun/bin:$PATH"` |

### Gotchas

- **webrick**: Jekyll 3.x on Ruby 3+ requires `gem "webrick"` in Gemfile (removed from stdlib in Ruby 3.0).
- **Bundle path**: Use `bundle config set --local path 'vendor/bundle'` to avoid system gem permission issues.
- **ctx.py singleton**: The `check_singleton()` in `ctx.py` greps `ps aux` for `ctx.py server` and may kill its own process. For testing, instantiate `MCPServer` directly in Python.
- **CosmoRun**: Requires `third_party/cosmocc/` (Cosmopolitan cross-compiler) which is in `.gitignore`. Not buildable without it.
- **Bun**: Installed to `~/.bun/bin/bun`; add to PATH before use.
- **Python packages**: `duckdb` and `pyyaml` are required by `products/ctx_store.py` and `products/ctx.mgr.py`.
