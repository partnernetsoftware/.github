//! Subprocess helpers — port of `nano_run_cli.c`.

use std::fs;
use std::path::Path;

use crate::lbin::fnv1a64;

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

pub fn read_file(path: &Path) -> i32 {
    let data = match fs::read(path) {
        Ok(d) => d,
        Err(_) => {
            eprintln!("read-file=read_fail path={}", path.display());
            return 1;
        }
    };
    println!("read-file.path={}", path.display());
    println!("read-file.bytes={}", data.len());
    println!("read-file.hash={:016x}", fnv1a64(&data));
    println!("read-file.ok=1");
    0
}

#[cfg(unix)]
pub fn spawn_wait(expected_s: &str, path: &Path, extra: &[String]) -> i32 {
    use std::process::{Command, Stdio};

    let expected: u64 = match expected_s.parse() {
        Ok(v) if v <= 255 => v,
        _ => {
            eprintln!("spawn-wait=bad_expected");
            return 1;
        }
    };
    let mut cmd = Command::new(path);
    for arg in extra {
        cmd.arg(arg);
    }
    cmd.stdin(Stdio::null());
    let status = match cmd.status() {
        Ok(s) => s,
        Err(_) => {
            eprintln!("spawn-wait=fork_fail path={}", path.display());
            return 2;
        }
    };
    println!("spawn-wait.path={}", path.display());
    println!("spawn-wait.expected={expected}");
    println!("spawn-wait.argc={}", 1 + extra.len());
    if let Some(code) = status.code() {
        println!("spawn-wait.actual={code}");
        if code as u64 == expected {
            println!("spawn-wait.ok=1");
            return 0;
        }
        eprintln!("spawn-wait=mismatch expected={expected} actual={code}");
        return 5;
    }
    eprintln!("spawn-wait=unknown_status");
    4
}

#[cfg(not(unix))]
pub fn spawn_wait(_expected_s: &str, path: &Path, _extra: &[String]) -> i32 {
    eprintln!("spawn-wait=unsupported_platform path={}", path.display());
    2
}

pub fn results_min(path: &Path, key: &str, min_s: &str) -> i32 {
    let min_v: i64 = match min_s.parse() {
        Ok(v) => v,
        Err(_) => return 2,
    };
    let content = match fs::read_to_string(path) {
        Ok(s) => s,
        Err(_) => {
            eprintln!("results-min=open_fail path={}", path.display());
            return 2;
        }
    };
    let needle = format!("{key}=");
    let mut val = -1i64;
    for line in content.lines() {
        if let Some(rest) = line.strip_prefix(&needle) {
            val = rest.trim().parse().unwrap_or(-1);
            break;
        }
    }
    if val < 0 {
        eprintln!("results-min=missing key={key}");
        return 2;
    }
    println!("results-min.key={key}");
    println!("results-min.val={val}");
    println!("results-min.min={min_v}");
    if val < min_v {
        return 2;
    }
    0
}
