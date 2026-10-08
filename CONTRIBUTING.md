# Contributing

Bug reports, documentation improvements, and focused pull requests are welcome.

Explain the problem and how to reproduce it before changing behavior. Keep changes small and preserve the native menu bar workflow. Discuss network access, telemetry, background services, or persistent setting changes before implementing them.

Build with `./script/build_and_run.sh --build-only`. For power-management changes, inspect `pmset -g assertions` and confirm the app assertions disappear after stop, expiry, and exit. Follow the checklist in [Development](docs/DEVELOPMENT.md).

Include macOS version, architecture, expected/observed results, reproduction steps, and verification evidence. Remove credentials and private desktop content from screenshots and logs.
