#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
require_tool git
relative=hardware/cpu/miniXiangShan
expected=$(git -C "$HISION_ROOT" rev-parse ":$relative")
if [[ ! -e "$CPU_ROOT/.git" ]]; then
  git -C "$HISION_ROOT" submodule update --init --recursive -- "$relative"
fi
actual=$(git -C "$CPU_ROOT" rev-parse HEAD)
[[ $actual == "$expected" ]] ||
  die "CPU checkout is $actual; the parent pins $expected. See docs/howto/dependencies.md."
[[ -z $(git -C "$CPU_ROOT" status --porcelain --untracked-files=normal) ]] ||
  die "CPU checkout has local modifications; preserve them before restoring the pinned baseline."
echo "CPU project: miniXiangShan $actual"
