use serde::Serialize;

#[derive(Serialize)]
pub struct WorkerStatus {
    app: &'static str,
    tauri: &'static str,
    headless: &'static str,
    hot_switch: &'static str,
    architecture: &'static str,
    note: &'static str,
}

#[derive(Serialize)]
struct WorkerOnce {
    app: &'static str,
    mode: &'static str,
    runtime: &'static str,
    headless: bool,
}

pub fn status() -> WorkerStatus {
    WorkerStatus {
        app: "tauri-worker",
        tauri: "v2",
        headless: "probe-only",
        hot_switch: "window visibility only",
        architecture: "worker-core + rust cli + optional tauri console",
        note: "Tauri still initializes the platform runtime; use --worker-once for true headless Rust work.",
    }
}

pub fn worker_once_json() -> String {
    serde_json::to_string(&WorkerOnce {
        app: "tauri-worker",
        mode: "worker-once",
        runtime: "rust-only",
        headless: true,
    })
    .expect("worker status should serialize")
}
