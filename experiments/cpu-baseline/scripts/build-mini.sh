#!/usr/bin/env bash
set -euo pipefail
COMPARE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export BUILD_DIR=${BUILD_DIR:-"$COMPARE_DIR/build"}
source "$COMPARE_DIR/../../scripts/common.sh"
bash "$HISION_ROOT/scripts/elaborate.sh" compare
{
  echo "miniXiangShan repository: https://github.com/XiangShanLab/miniXiangShan.git"
  echo "miniXiangShan revision: $(git -C "$CPU_ROOT" rev-parse HEAD)"
} >> "$BUILD_DIR/dependencies.txt"
obj="$BUILD_DIR/obj/mini"
mkdir -p "$obj"
OBJCACHE= "$VERILATOR" --cc --exe --build -j "$JOBS" --assert \
  --top-module MiniPerfTop -Wno-fatal -Wno-lint -Wno-style \
  -O2 --x-assign fast --x-initial fast --Mdir "$obj" \
  "$RTL_DIR/compare/mini/"*.v \
  "$COMPARE_DIR/platform/rtl/Axi4PerfPlatform.v" \
  "$COMPARE_DIR/platform/tb/mini_main.cpp" -o mini-emu
install -m 755 "$obj/mini-emu" "$BUILD_DIR/mini-emu"
