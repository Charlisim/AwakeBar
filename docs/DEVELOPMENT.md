# Development

## Architecture

`Sources/AwakeBar/main.swift` contains the AppKit entry point and main-thread delegate. It owns the status item, menu, timer, dialogs, About window, and IOKit assertion IDs. A one-second timer updates the countdown; user activity is declared every 25 seconds. A new display assertion is acquired before replacing an existing session, so acquisition failure preserves the old session.

The menu is constructed once. Its heading and stop state update without rebuilding an open native menu. The About window shares the menu's duration actions.

SwiftPM targets macOS 14+. The staged app uses `LSUIElement=true` (no Dock icon) and bundle ID `com.softlari.awakebar`.

## Build scripts

- `script/build_and_run.sh`: build, stage, sign, launch. Flags: `--build-only`, `--verify`, `--debug`, `--logs`, `--telemetry`.
- `script/install.sh [directory]`: universal release build and installation; defaults to `~/Applications`. Existing installations are backed up.
- `script/package.sh`: universal ZIP and `SHA256SUMS`.
- `script/generate_icon.swift`: original cup icon artwork generator.

Use `CONFIGURATION=release UNIVERSAL=1 ./script/build_and_run.sh --build-only` for a universal release. Normal builds target the host. `open dist/AwakeBar.app --args --about` opens the About window.

## Manual verification

1. Start inactive with no app power assertion.
2. Select each preset and check the countdown.
3. Select indefinite mode; verify `∞` and an AwakeBar assertion in `pmset -g assertions`.
4. Replace the session and confirm no stale assertion remains.
5. Set one minute; wait for expiry and confirm assertion release.
6. Submit blank, zero, negative, decimal, nonnumeric, or excessive custom input; confirm no new session starts.
7. Cancel custom input; preserve the previous session.
8. Stop and quit; confirm assertion release.
9. Check actual idle/lock behavior against the target Mac's settings. Manual lock and managed policies remain functional.

A universal binary does not prove Intel runtime behavior. Ad hoc signing is used locally; notarization requires Developer ID credentials.

## Website

`website/` contains the English landing page and Cloudflare config for `awakebar.csimon.dev`. Downloads use GitHub Releases. No analytics, remote fonts, or backend dependencies are included.

Run `npm ci`, `npm run dev`, or `npm run deploy` from `website/` using your authenticated Wrangler session. Never commit tokens or credentials.
