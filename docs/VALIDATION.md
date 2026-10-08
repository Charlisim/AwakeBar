# Release 1.0.0 validation

Validated on 2026-10-07 on an Apple Silicon Mac.

- Universal release compiled; binary contains arm64 and x86_64 slices.
- Bundle identifier: com.softlari.awakebar. Info.plist and ad hoc signature validated.
- Installed in the user Applications folder and process launch confirmed.
- Custom input of zero rejected through the actual UI.
- A custom one-minute session created both PreventUserIdleDisplaySleep and UserIsActive assertions owned by AwakeBar, observed using pmset.
- After expiry, AwakeBar assertions were absent and the menu showed Your Mac can sleep.
- Indefinite mode created assertions; Allow sleep released them.
- Screenshots show the real About window and custom duration dialog.
- Release ZIP integrity and SHA-256 checksum validated.
- Cloudflare deployed awakebar.csimon.dev; HTTPS returned 200 with the configured content headers.

Intel runtime and real automatic-lock behavior against all screen saver/managed-policy settings remain unverified. Other running apps held their own sleep assertions during these checks, so this is evidence of AwakeBar assertion acquisition/release, not an isolated end-to-end system sleep test.
