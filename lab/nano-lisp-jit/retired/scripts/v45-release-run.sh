#!/usr/bin/env bash
# 发行面工厂入口：显式瘦 run.sh（不冒充默认无参 run.sh 已瘦）.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
export NANO_V45_SCOPED_ONLY=1
export NANO_V45_RELEASE_FACTORY=1
cd "$ROOT"
echo "v45-release-run=begin scoped_only=1"
exec bash "$ROOT/lab/nano-lisp-jit/run.sh" "$@"
