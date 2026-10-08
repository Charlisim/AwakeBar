#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESTINATION="${1:-$HOME/Applications}/AwakeBar.app"
CONFIGURATION=release UNIVERSAL=1 "$ROOT_DIR/script/build_and_run.sh" --build-only
if [[ -e "$DESTINATION" ]]; then
  BACKUP="${DESTINATION%.app}-backup-$(date +%Y%m%d-%H%M%S).app"
  mv "$DESTINATION" "$BACKUP"
  echo "Previous installation saved to $BACKUP"
fi
mkdir -p "$(dirname "$DESTINATION")"
pkill -x AwakeBar >/dev/null 2>&1 || true
ditto --norsrc --noextattr "$ROOT_DIR/dist/AwakeBar.app" "$DESTINATION"
codesign --verify --strict "$DESTINATION"
open -n "$DESTINATION"
echo "Installed $DESTINATION"
