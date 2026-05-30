#!/usr/bin/env bash
# Enable Workers AI + Vectorize for mem_search, then redeploy.
set -euo pipefail
cd "$(dirname "$0")/.."
INDEX="${MEM_VECTORIZE_INDEX:-mcp-cf-bots-mem}"
WRANGLER=wrangler.toml

echo "==> Vectorize index: $INDEX"
npx wrangler vectorize create "$INDEX" --dimensions=768 --metric=cosine

echo "==> metadata index: owner"
npx wrangler vectorize create-metadata-index "$INDEX" --property-name=owner --type=string

if grep -q '^# \[ai\]' "$WRANGLER" 2>/dev/null; then
  echo "==> enabling AI + MEM_VECTORS in $WRANGLER"
  sed -i 's/^# \[ai\]/[ai]/' "$WRANGLER"
  sed -i 's/^# binding = "AI"/binding = "AI"/' "$WRANGLER"
  sed -i 's/^# \[\[vectorize\]\]/[[vectorize]]/' "$WRANGLER"
  sed -i 's/^# binding = "MEM_VECTORS"/binding = "MEM_VECTORS"/' "$WRANGLER"
  sed -i 's/^# index_name = "mcp-cf-bots-mem"/index_name = "mcp-cf-bots-mem"/' "$WRANGLER"
fi

echo "==> deploy"
npx wrangler deploy --name mcp-cf-bots
echo "Check: curl -s \"\$MCP_CF_BOTS_URL/health\" | jq .features"
