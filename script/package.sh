#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGURATION=release UNIVERSAL=1 "$ROOT_DIR/script/build_and_run.sh" --build-only
cd "$ROOT_DIR/dist"
COPYFILE_DISABLE=1 /usr/bin/zip -q -r -X AwakeBar-1.0.0-macos-universal.zip AwakeBar.app
shasum -a 256 AwakeBar-1.0.0-macos-universal.zip > SHA256SUMS
echo "Created dist/AwakeBar-1.0.0-macos-universal.zip"
