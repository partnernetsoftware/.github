//! APE run-ape — memfd-first Linux loader + tmpfile/QEMU fallback.

use super::v2::{load_v2, select_slice};
use std::fs;
use std::io::{self, Write};
use std::path::Path;

#[cfg(unix)]
use std::os::unix::fs::PermissionsExt;

pub fn run_ape(path: &Path, force_arch: Option<&str>) -> i32 {
    let data = match fs::read(path) {
        Ok(d) => d,
        Err(_) => {
            let _ = writeln!(io::stderr(), "read=fail path={}", path.display());
            return 1;
        }
    };
    let img = match load_v2(&data, "run-ape") {
        Ok(i) => i,
        Err(code) => return code,
    };
    let (row, arch_name) = match select_slice(&img, force_arch) {
        Ok(v) => v,
        Err(code) => return code,
    };
    let slice = match img.slice_bytes(&data, row) {
        Some(s) => s,
        None => {
            let _ = writeln!(io::stderr(), "run-ape=bad_slice_bounds arch={arch_name}");
            return 4;
        }
    };
    println!("run-ape.path={}", path.display());
    println!("run-ape.container=ape-v2");
    println!("run-ape.arch={arch_name}");
    println!("run-ape.offset={}", row.offset);
    println!("run-ape.size={}", row.size);
    if let Some(f) = force_arch {
        println!("run-ape.force_arch={f}");
    }
    println!("run-ape.payload.load=1");
    println!("run-ape.payload.arch={arch_name}");
    println!("run-ape.payload.size={}", slice.len());
    let rc = extract_and_run_slice(slice, arch_name);
    println!("run-ape.exit={rc}");
    rc
}

pub fn run_ape_expect_exit(path: &Path, expected_s: &str, force_arch: Option<&str>) -> i32 {
    let expected: i32 = match expected_s.parse() {
        Ok(v) => v,
        Err(_) => {
            let _ = writeln!(io::stderr(), "run-ape-expect-exit=bad_expected");
            return 4;
        }
    };
    let actual = run_ape(path, force_arch);
    println!("run-ape-expect-exit.path={}", path.display());
    println!("run-ape-expect-exit.expected={expected}");
    println!("run-ape-expect-exit.actual={actual}");
    if actual == expected {
        println!("run-ape-expect-exit.ok=1");
        0
    } else {
        let _ = writeln!(
            io::stderr(),
            "run-ape-expect-exit=mismatch expected={expected} actual={actual}"
        );
        5
    }
}

fn host_matches_slice(arch_name: &str) -> bool {
    matches!(
        (std::env::consts::ARCH, arch_name),
        ("x86_64", "x86_64") | ("aarch64", "aarch64")
    )
}

fn find_qemu_aarch64() -> Option<&'static str> {
    for c in ["/usr/bin/qemu-aarch64-static", "/usr/bin/qemu-aarch64"] {
        let p = Path::new(c);
        if p.is_file() && is_executable(p) {
            return Some(c);
        }
    }
    None
}

#[cfg(unix)]
fn is_executable(path: &Path) -> bool {
    path.metadata()
        .map(|m| m.permissions().mode() & 0o111 != 0)
        .unwrap_or(false)
}

fn extract_and_run_slice(slice: &[u8], arch_name: &str) -> i32 {
    #[cfg(target_os = "linux")]
    if host_matches_slice(arch_name) && super::is_elf(slice) {
        if let Some(rc) = run_elf_memfd_linux(slice) {
            return rc;
        }
    }

    #[cfg(unix)]
    {
        return run_elf_tmpfile_unix(slice, arch_name);
    }

    #[cfg(not(unix))]
    {
        let _ = writeln!(io::stderr(), "run-ape=unsupported_platform");
        2
    }
}

#[cfg(target_os = "linux")]
fn run_elf_memfd_linux(elf: &[u8]) -> Option<i32> {
    use std::process::Command;

    let fd = unsafe { libc::memfd_create(b"nano-ape\0".as_ptr() as *const _, 0) };
    if fd < 0 {
        return None;
    }
    let written =
        unsafe { libc::write(fd, elf.as_ptr() as *const _, elf.len()) };
    if written != elf.len() as isize {
        unsafe { libc::close(fd) };
        return None;
    }
    let proc_path = format!("/proc/self/fd/{fd}");
    let status = Command::new(&proc_path).status().ok()?;
    unsafe { libc::close(fd) };
    println!("run-ape.loader=memfd");
    Some(status.code().unwrap_or(3))
}

#[cfg(unix)]
fn run_elf_tmpfile_unix(slice: &[u8], arch_name: &str) -> i32 {
    use std::ffi::CString;
    use std::process::Command;

    let tmpl = match CString::new("/tmp/nano-ape-XXXXXX") {
        Ok(s) => s,
        Err(_) => return 3,
    };
    let fd = unsafe { libc::mkstemp(tmpl.as_ptr() as *mut _) };
    if fd < 0 {
        let _ = writeln!(io::stderr(), "run-ape=mkstemp_fail arch={arch_name}");
        return 3;
    }
    unsafe { libc::close(fd) };
    let path = Path::new(tmpl.to_str().unwrap_or("/tmp/nano-ape-fail"));
    if fs::write(path, slice).is_err() {
        let _ = fs::remove_file(path);
        let _ = writeln!(io::stderr(), "run-ape=write_fail arch={arch_name}");
        return 3;
    }
    if fs::set_permissions(path, fs::Permissions::from_mode(0o755)).is_err() {
        let _ = fs::remove_file(path);
        let _ = writeln!(io::stderr(), "run-ape=chmod_fail arch={arch_name}");
        return 3;
    }

    let status = if arch_name == "aarch64" && std::env::consts::ARCH == "x86_64" {
        let Some(qemu) = find_qemu_aarch64() else {
            let _ = fs::remove_file(path);
            let _ = writeln!(io::stderr(), "run-ape=qemu_missing arch=aarch64");
            return 126;
        };
        Command::new(qemu).arg(path).status()
    } else {
        Command::new(path).status()
    };

    let _ = fs::remove_file(path);
    match status {
        Ok(s) => {
            println!("run-ape.loader=tmpfile");
            s.code().unwrap_or(3)
        }
        Err(_) => {
            let _ = writeln!(io::stderr(), "run-ape=wait_fail arch={arch_name}");
            3
        }
    }
}
