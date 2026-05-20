# tauri-worker

Small Tauri v2 experiment app for checking whether Tauri can be used as a
headless worker.

## What this explores

Tauri v2 can be configured with no startup windows (`app.windows: []`) and a
window can be created later from Rust. This is useful for app startup control,
but it is not the same thing as a native headless runtime.

On Linux, Tauri still initializes the desktop runtime and WebView stack. In a
real headless environment without a display server, the Tauri runtime path is
expected to fail or require a virtual display such as Xvfb. The truly headless
path for worker logic is to run Rust code before initializing Tauri at all.

## Commands

```bash
npm install
npm run tauri dev
npm run worker:once
npm run headless:probe
npm run release:size
```

## Experiment modes

- `npm run tauri dev`: normal Tauri window mode.
- `npm run worker:once`: Rust-only worker path; exits before Tauri initializes.
- `npm run headless:probe`: initializes Tauri with zero windows and exits from
  setup. This tests "no window" behavior, not true headless WebView rendering.
- The UI has a "Runtime switch probe" button that hides and restores the window
  at runtime. It proves visibility can change without restart, but the display
  runtime remains active.

## Current conclusion

Tauri v2 is window-optional at startup, but not headless-native. For background
worker experiments, keep the worker code in Rust before `tauri::Builder` starts,
or run Tauri under a virtual display when WebView APIs are required.

Because headless is not native, there is no smooth no-restart switch between a
real display-free Tauri runtime and a headed WebView runtime. A running Tauri app
can create, hide, show, or close windows, but that is only headed/windowless
state inside the same desktop runtime.

For a browser-use style worker, use the architecture in `ARCHITECTURE.md`: keep
automation in a Tauri-free worker core and treat Tauri as an optional local
console.

## Release size

On this Linux build, the optimized Tauri executable is `4,071,744 bytes` (`3.9M`).
The docs' sub-1MB number is possible for highly minimal optimized apps, but this
sample does not reach it.

References:

- https://v2.tauri.app/reference/config/#appconfig
- https://v2.tauri.app/develop/
