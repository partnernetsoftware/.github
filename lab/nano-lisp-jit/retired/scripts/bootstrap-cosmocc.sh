#!/usr/bin/env bash
# Bootstrap cosmocc into workspace/third_party/cosmocc (symlink or extract).
# Honest skip on failure (exit 0). Used for C shell P0 promote prep.
# Optional: NANO_BOOTSTRAP_COSMOCC=1 before nano-jit-c-shell-promote-smoke.sh
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
TARGET="$ROOT/third_party/cosmocc"
COSMO_BIN="$TARGET/bin"
CC="$COSMO_BIN/x86_64-unknown-cosmo-cc"
COSMOCC_VERSION="${COSMOCC_VERSION:-4.0.2}"
GITHUB_REPO="${GITHUB_REPO:-jart/cosmopolitan}"

cosmocc_usable() {
  local dir="${1:-}"
  [ -n "$dir" ] && [ -x "$dir/x86_64-unknown-cosmo-cc" ]
}

skip() {
  echo "bootstrap-cosmocc=skip reason=$1"
  exit 0
}

verify_and_ok() {
  local dir="$1"
  local cc="$dir/x86_64-unknown-cosmo-cc"
  if ! cosmocc_usable "$dir"; then
    skip "verify_missing_cc"
  fi
  local ver
  if ! ver=$("$cc" -v 2>&1); then
    ver=$("$cc" --version 2>&1) || skip "verify_cc_version"
  fi
  echo "bootstrap-cosmocc=ok dir=$dir"
  echo "$ver" | head -3
  exit 0
}

if cosmocc_usable "$COSMO_BIN"; then
  verify_and_ok "$COSMO_BIN"
fi

if cosmocc_usable "/opt/cosmocc/bin"; then
  mkdir -p "$ROOT/third_party"
  ln -sfn /opt/cosmocc "$TARGET"
  verify_and_ok "$COSMO_BIN"
fi

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  skip "no_curl_wget"
fi

if ! command -v unzip >/dev/null 2>&1; then
  skip "no_unzip"
fi

network_ok() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSIL --max-time 20 "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" >/dev/null 2>&1
    return $?
  fi
  wget -q --spider --timeout=20 "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" 2>/dev/null
}

if ! network_ok; then
  skip "network_unreachable"
fi

resolve_cosmocc_zip_url() {
  local tag="${1:-}"
  local api="https://api.github.com/repos/${GITHUB_REPO}/releases/tags/${tag}"
  local gh_url=""
  if command -v curl >/dev/null 2>&1; then
    gh_url=$(curl -fsSL --max-time 30 "$api" 2>/dev/null | python3 -c "
import json, sys
r = json.load(sys.stdin)
for a in r.get('assets', []):
    n = a.get('name', '')
    if n.startswith('cosmocc-') and n.endswith('.zip'):
        print(a['browser_download_url'])
        break
" 2>/dev/null || true)
  fi
  if [ -n "$gh_url" ]; then
    printf '%s\n' "$gh_url"
    return 0
  fi
  printf '%s\n' \
    "https://github.com/${GITHUB_REPO}/releases/download/${tag}/cosmocc-${tag}.zip" \
    "https://cosmo.zip/pub/cosmocc/cosmocc-${tag}.zip"
}

download_zip() {
  local dest="$1"
  shift
  local url
  for url in "$@"; do
    [ -n "$url" ] || continue
    if command -v curl >/dev/null 2>&1; then
      if curl -fSL --max-time 600 "$url" -o "$dest" 2>/dev/null && [ -s "$dest" ]; then
        return 0
      fi
    elif command -v wget >/dev/null 2>&1; then
      if wget -q --timeout=600 -O "$dest" "$url" 2>/dev/null && [ -s "$dest" ]; then
        return 0
      fi
    fi
    rm -f "$dest"
  done
  return 1
}

TAG="$COSMOCC_VERSION"
mapfile -t URLS < <(resolve_cosmocc_zip_url "$TAG")
if [ "${#URLS[@]}" -eq 0 ] || [ -z "${URLS[0]:-}" ]; then
  URLS=(
    "https://github.com/${GITHUB_REPO}/releases/download/${TAG}/cosmocc-${TAG}.zip"
    "https://cosmo.zip/pub/cosmocc/cosmocc-${TAG}.zip"
  )
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
ZIP="$TMP/cosmocc.zip"
STAGE="$TMP/stage"

if ! download_zip "$ZIP" "${URLS[@]}"; then
  skip "download_failed"
fi

mkdir -p "$STAGE"
if ! unzip -q "$ZIP" -d "$STAGE" 2>/dev/null; then
  skip "unzip_failed"
fi

install_from_stage() {
  local stage="$1"
  if cosmocc_usable "$stage/bin"; then
    mkdir -p "$ROOT/third_party"
    rm -rf "$TARGET"
    mv "$stage" "$TARGET"
    return 0
  fi
  local found
  found="$(find "$stage" -name x86_64-unknown-cosmo-cc -type f 2>/dev/null | head -1)"
  if [ -z "$found" ]; then
    return 1
  fi
  local bindir rootdir
  bindir="$(dirname "$found")"
  rootdir="$(dirname "$bindir")"
  mkdir -p "$ROOT/third_party"
  rm -rf "$TARGET"
  mv "$rootdir" "$TARGET"
  return 0
}

if ! install_from_stage "$STAGE"; then
  skip "layout_unrecognized"
fi

verify_and_ok "$COSMO_BIN"
