use serde_json::json;
use std::time::Duration;

#[tauri::command]
fn worker_status() -> serde_json::Value {
    json!({
        "app": "tauri-worker",
        "tauri": "v2",
        "headless": "probe-only",
        "hot_switch": "window visibility only",
        "note": "Tauri still initializes the platform runtime; use --worker-once for true headless Rust work."
    })
}

#[tauri::command]
fn hide_then_restore(window: tauri::WebviewWindow) -> Result<&'static str, String> {
    window.hide().map_err(|error| error.to_string())?;

    std::thread::spawn(move || {
        std::thread::sleep(Duration::from_secs(1));
        if let Err(error) = window.show() {
            eprintln!("tauri-worker: failed to restore window: {error}");
            return;
        }
        if let Err(error) = window.set_focus() {
            eprintln!("tauri-worker: failed to focus restored window: {error}");
        }
    });

    Ok("window hidden for one second, then restored; runtime stayed headed")
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum RunMode {
    Window,
    HeadlessProbe,
}

impl RunMode {
    fn from_args() -> Self {
        if std::env::args().any(|arg| arg == "--headless-probe") {
            Self::HeadlessProbe
        } else {
            Self::Window
        }
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let mode = RunMode::from_args();

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![worker_status, hide_then_restore])
        .setup(move |app| {
            if mode == RunMode::HeadlessProbe {
                eprintln!("tauri-worker: Tauri runtime started with zero windows configured.");
                let handle = app.handle().clone();
                std::thread::spawn(move || {
                    std::thread::sleep(Duration::from_millis(250));
                    eprintln!("tauri-worker: no-window probe reached setup; exiting.");
                    handle.exit(0);
                });
                return Ok(());
            }

            tauri::WebviewWindowBuilder::new(
                app,
                "main",
                tauri::WebviewUrl::App("index.html".into()),
            )
            .title("tauri-worker")
            .inner_size(800.0, 600.0)
            .build()?;

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
