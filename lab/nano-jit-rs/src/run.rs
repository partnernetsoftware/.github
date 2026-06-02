//! Subprocess helpers — port of `nano_run_cli.c`.

use std::path::Path;

#[cfg(unix)]
pub fn run_expect_exit(path: &Path, expected_s: &str) -> i32 {
    use std::process::Command;

    let expected: u64 = match expected_s.parse() {
        Ok(v) if v <= 255 => v,
        _ => {
            eprintln!("run-expect-exit=bad_expected");
            return 1;
        }
    };

    let status = match Command::new(path).status() {
        Ok(s) => s,
        Err(_) => {
            eprintln!("run-expect-exit=fork_fail path={}", path.display());
            return 2;
        }
    };

    println!("run-expect-exit.path={}", path.display());
    println!("run-expect-exit.expected={expected}");
    if let Some(code) = status.code() {
        println!("run-expect-exit.actual={code}");
        if code as u64 == expected {
            println!("run-expect-exit.ok=1");
            return 0;
        }
        eprintln!("run-expect-exit=mismatch expected={expected} actual={code}");
        return 5;
    }
    eprintln!("run-expect-exit=unknown_status");
    4
}

#[cfg(not(unix))]
pub fn run_expect_exit(path: &Path, _expected_s: &str) -> i32 {
    eprintln!("run-expect-exit=unsupported_platform path={}", path.display());
    2
}
