# Browser-use worker architecture

Goal: keep browser automation headless, and use Tauri only as an optional local
control console.

## Shape

```text
browser-use client
  -> rust worker cli / stdio server
    -> worker-core
      -> browser adapter
  -> optional tauri console
    -> worker-core status and controls
```

## Process model

- `worker-core`: plain Rust module for task state, browser sessions, logs, and
  health checks. It must not depend on Tauri.
- `--worker-once`: true headless path. It exits before `tauri::Builder` starts.
- `npm run tauri dev`: headed console for local inspection and controls.
- `npm run headless:probe`: proves that no startup window still initializes the
  Linux desktop runtime, so it is not a real display-free mode.

## Switching model

Do not switch one Tauri process between true headless and headed. Keep the worker
as the durable process, then attach or detach the Tauri console as a separate
headed surface. Inside one Tauri process, hiding/showing windows is only window
visibility switching.

## Size result on this Linux build

Measured with `npm run tauri build` on Cursor Cloud:

- default release before size work: `14,011,760 bytes` (`14M`)
- optimized release after removing the opener plugin and enabling the stable
  Cargo size profile: `4,071,744 bytes` (`3.9M`)

The Tauri docs' sub-1MB claim is a lower-bound possibility for highly minimal
apps and optimized builds, not a guarantee for this Linux WebView sample. For a
browser-use worker, the browser/runtime strategy will matter more than the Tauri
launcher binary size.
