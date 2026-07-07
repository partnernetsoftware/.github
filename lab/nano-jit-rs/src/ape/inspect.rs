//! APE v2 inspect — port of C `inspect-ape`.

use super::v2::load_v2;
use std::fs;
use std::io::{self, Write};
use std::path::Path;

pub fn inspect_ape(path: &Path) -> i32 {
    let data = match fs::read(path) {
        Ok(d) => d,
        Err(_) => {
            let _ = writeln!(io::stderr(), "inspect-ape=read_fail");
            return 2;
        }
    };
    let img = match load_v2(&data, "inspect-ape") {
        Ok(i) => i,
        Err(code) => return code,
    };
    println!("inspect-ape.path={}", path.display());
    println!("inspect-ape.container=ape-v2");
    println!("inspect-ape.header_bytes={}", img.header_bytes);
    println!("inspect-ape.slice_count={}", img.slice_count);
    for (i, row) in img.slices.iter().enumerate() {
        println!("inspect-ape.slice.{i}.arch_id={}", row.arch_id);
        println!("inspect-ape.slice.{i}.os_id={}", row.os_id);
        println!("inspect-ape.slice.{i}.offset={}", row.offset);
        println!("inspect-ape.slice.{i}.size={}", row.size);
        println!("inspect-ape.slice.{i}.hash={:016x}", row.hash);
    }
    println!("inspect-ape.universal.loader=v2-payload-table");
    println!("inspect-ape.ok=1");
    0
}
