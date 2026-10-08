#!/usr/bin/env bash
set -euo pipefail
MODE="${1:-run}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
export CLANG_MODULE_CACHE_PATH="$ROOT_DIR/.build/clang-cache"
CONFIGURATION="${CONFIGURATION:-debug}"
if [[ "${UNIVERSAL:-0}" == "1" ]]; then
  swift build --disable-sandbox --cache-path "$ROOT_DIR/.build/cache" -c "$CONFIGURATION" --arch arm64 --arch x86_64
else
  swift build --disable-sandbox --cache-path "$ROOT_DIR/.build/cache" -c "$CONFIGURATION"
fi
if [[ "${UNIVERSAL:-0}" == "1" ]]; then
  BINARY="$(swift build --disable-sandbox -c "$CONFIGURATION" --arch arm64 --arch x86_64 --show-bin-path)/AwakeBar"
else
  BINARY="$(swift build --disable-sandbox -c "$CONFIGURATION" --show-bin-path)/AwakeBar"
fi
BUNDLE="$ROOT_DIR/dist/AwakeBar.app"
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"
cp "$BINARY" "$BUNDLE/Contents/MacOS/AwakeBar"
cat > "$BUNDLE/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>AwakeBar</string>
<key>CFBundleIdentifier</key><string>com.softlari.awakebar</string>
<key>CFBundleName</key><string>AwakeBar</string>
<key>CFBundleVersion</key><string>1</string>
<key>CFBundleShortVersionString</key><string>1.0.0</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>NSPrincipalClass</key><string>NSApplication</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
cp "$ROOT_DIR/Resources/AppIcon.icns" "$BUNDLE/Contents/Resources/AppIcon.icns"
xattr -cr "$BUNDLE"
codesign --force --sign - "$BUNDLE"
if [[ "$MODE" == "--build-only" ]]; then exit 0; fi
pkill -x AwakeBar >/dev/null 2>&1 || true
case "$MODE" in
run) open -n "$BUNDLE" ;;
--verify) open -n "$BUNDLE"; sleep 1; pgrep -x AwakeBar ;;
--debug) lldb -- "$BUNDLE/Contents/MacOS/AwakeBar" ;;
--logs|--telemetry) open -n "$BUNDLE"; /usr/bin/log stream --info --style compact --predicate 'process == "AwakeBar"' ;;
*) echo "Unknown mode: $MODE" >&2; exit 2 ;;
esac
