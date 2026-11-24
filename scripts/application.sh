#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
action=${1:-}
app=${2:-hello}
[[ $app =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] || die "invalid application name: $app"
directory="$HISION_ROOT/software/apps/$app"
[[ -f "$directory/Makefile" ]] || die "application not found: $directory"
case $action in
  build) exec make -C "$directory" ;;
  run)
    [[ -x "$BUILD_DIR/emu" ]] || die "build the simulator first: make emu"
    image="$directory/build/$app.bin"
    [[ -f "$image" ]] || die "build the application first: make app APP=$app"
    exec "$BUILD_DIR/emu" -i "$image"
    ;;
  *) die "Usage: $0 build|run APP" ;;
esac
