// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    if std::env::args().any(|arg| arg == "--worker-once") {
        println!("{}", tauri_worker_lib::worker::worker_once_json());
        return;
    }

    tauri_worker_lib::run()
}
