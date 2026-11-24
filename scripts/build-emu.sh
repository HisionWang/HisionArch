#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
WITH_DIFFTEST=${WITH_DIFFTEST:-1}
WITH_WAVE=${WITH_WAVE:-1}
[[ $WITH_DIFFTEST =~ ^[01]$ && $WITH_WAVE =~ ^[01]$ ]] ||
  die "WITH_DIFFTEST and WITH_WAVE must be 0 or 1"
require_tool "$VERILATOR"
bash "$HISION_ROOT/scripts/deps.sh"
mkdir -p "$BUILD_DIR"
exec 8>"$BUILD_DIR/.emu.lock"
flock 8
if [[ $WITH_DIFFTEST == 1 ]]; then
  bash "$HISION_ROOT/scripts/build-ref.sh"
fi
bash "$HISION_ROOT/scripts/elaborate.sh" emu
obj="$BUILD_DIR/obj/emu-d$WITH_DIFFTEST-w$WITH_WAVE"
mkdir -p "$obj"
trace_args=()
[[ $WITH_WAVE == 0 ]] || trace_args=(--trace-fst)
OBJCACHE= "$VERILATOR" --cc --exe --build -j "$JOBS" --assert \
  --top-module core_top -Wno-fatal -Wno-lint -Wno-style \
  "${trace_args[@]}" --Mdir "$obj" \
  -CFLAGS "-std=c++17 -DWITH_DIFFTEST=$WITH_DIFFTEST -DEMU_TRACE=$WITH_WAVE " \
  -LDFLAGS "-ldl" \
  "$RTL_DIR/emu/"*.v "$CPU_ROOT/difftest/csrc/emu.cpp" -o emu
install -m 755 "$obj/emu" "$BUILD_DIR/emu"
echo
echo "Simulator: $BUILD_DIR/emu (difftest=$WITH_DIFFTEST, waveform support=$WITH_WAVE)"
echo "Build an app:  make -C $HISION_ROOT/software/apps/hello"
echo "Run manually: $BUILD_DIR/emu -i $HISION_ROOT/software/apps/hello/build/hello.bin"
echo "Options:      $BUILD_DIR/emu --help"
