#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
[[ $BUILD_DIR == "$HISION_ROOT/build" || $BUILD_DIR == "$HISION_ROOT/build/"* ]] ||
  die "refusing to clean this BUILD_DIR: $BUILD_DIR"
rm -rf -- "$BUILD_DIR" "$HISION_ROOT/target" "$HISION_ROOT/project/target" \
  "$HISION_ROOT/project/project"
echo "Removed root build products and Scala caches. Source configuration, dependencies, apps and experiment results are retained."
