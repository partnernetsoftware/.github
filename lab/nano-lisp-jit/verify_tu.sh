#!/usr/bin/env bash
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lispjit-ir" && pwd)"
cc -Os -s -Wall -Wextra lispjit.c -ldl -o /tmp/lispjit-probe
printf 'verify-tu.ok=1\n'
