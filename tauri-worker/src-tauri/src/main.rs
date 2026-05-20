// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    if std::env::args().any(|arg| arg == "--worker-once") {
        println!(
            "{{\"app\":\"tauri-worker\",\"mode\":\"worker-once\",\"runtime\":\"rust-only\",\"headless\":true}}"
        );
        return;
    }

    tauri_worker_lib::run()
}
