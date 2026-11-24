#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
case ${1:-} in
  emu) mode=emu; top=core_top; output="$RTL_DIR/emu" ;;
  compare) mode=compare; top=MiniPerfTop; output="$RTL_DIR/compare/mini" ;;
  fpga) mode=fpga; top=core_top; output="$RTL_DIR/fpga" ;;
  *) die "Usage: $0 emu|compare|fpga" ;;
esac
bash "$HISION_ROOT/scripts/deps.sh"
find_sbt
mkdir -p "$BUILD_DIR"
# Both elaborations share sbt's target/ directory.
exec 9>"$HISION_ROOT/.build.lock"
flock 9
properties="$HISION_ROOT/project/build.properties"
cpu_revision=$(git -C "$CPU_ROOT" rev-parse HEAD)
key=$(fingerprint --value "$mode,$SBT,$cpu_revision" \
  "$CPU_ROOT/src/main/scala" "$HISION_ROOT/hardware/accelerators" \
  "$HISION_ROOT/hardware/soc" "$HISION_ROOT/hardware/memory" \
  "$HISION_ROOT/hardware/common" "$HISION_ROOT/hardware/platform" "$HISION_ROOT/build.sbt" \
  "$properties" "$HISION_ROOT/scripts/elaborate.sh" \
  "$HISION_ROOT/scripts/common.sh")
if [[ -f "$output/$top.v" && -f "$output/.source-hash" &&
      $(<"$output/.source-hash") == "$key" ]]; then
  echo "Reusing $mode RTL: $output"
  exit 0
fi
runtime_dir="${TMPDIR:-/tmp}/hisionarch-sbt-${UID:-0}"
mkdir -p "$runtime_dir"
chmod 700 "$runtime_dir"
cd "$HISION_ROOT"
rm -rf -- "$output"
XDG_RUNTIME_DIR="$runtime_dir" "$SBT" --server -batch "runMain hisionarch.platform.Generate $mode"
printf '%s\n' "CPU_REPOSITORY=https://github.com/XiangShanLab/miniXiangShan.git" \
  "CPU_REVISION=$cpu_revision" "MODE=$mode" "SOURCE_FINGERPRINT=$key" \
  > "$output/build-context.txt"
printf '%s\n' "$key" > "$output/.source-hash"
