#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
bash "$HISION_ROOT/scripts/deps.sh"
# Reuse the reference ABI, lockfile, and build logic belonging to this CPU.
exec bash "$CPU_ROOT/scripts/build-ref.sh"
