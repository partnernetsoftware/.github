#!/usr/bin/env bash
# Create Vectorize index + metadata filter, enable binding in wrangler.toml, deploy.
# Requires API token with: Workers Scripts Edit + Vectorize Edit.
set -euo pipefail
cd "$(dirname "$0")/.."
INDEX="${MEM_VECTORIZE_INDEX:-mcp-cf-bots-mem}"
WRANGLER=wrangler.toml

echo "==> Vectorize index: $INDEX (768-dim cosine)"
if ! npx wrangler vectorize create "$INDEX" --dimensions=768 --metric=cosine 2>/dev/null; then
  echo "    (index may already exist)"
fi

echo "==> metadata index: owner"
npx wrangler vectorize create-metadata-index "$INDEX" --property-name=owner --type=string 2>/dev/null || true

if ! grep -q '^\[\[vectorize\]\]' "$WRANGLER"; then
  echo "==> enabling Vectorize + AI in $WRANGLER"
  if grep -q '^# \[\[vectorize\]\]' "$WRANGLER"; then
    sed -i 's/^# \[ai\]/[ai]/' "$WRANGLER"
    sed -i 's/^# binding = "AI"/binding = "AI"/' "$WRANGLER"
    sed -i 's/^# \[\[vectorize\]\]/[[vectorize]]/' "$WRANGLER"
    sed -i 's/^# binding = "MEM_VECTORS"/binding = "MEM_VECTORS"/' "$WRANGLER"
    sed -i 's/^# index_name = "mcp-cf-bots-mem"/index_name = "mcp-cf-bots-mem"/' "$WRANGLER"
  else
    cat >> "$WRANGLER" <<'EOF'

[ai]
binding = "AI"

[[vectorize]]
binding = "MEM_VECTORS"
index_name = "mcp-cf-bots-mem"
EOF
  fi
fi

echo "==> deploy worker"
npx wrangler deploy --name mcp-cf-bots
echo "Done. curl \$MCP_CF_BOTS_URL/health → rag_backend should be vectorize"
