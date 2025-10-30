// Rust with crc32c crate optimization
use crc32c::crc32c;

const BUFFER_SIZE: usize = 10 * 1024 * 1024;

fn make_buffer() -> Vec<u8> {   // generate 10MB of buffer
    (0..BUFFER_SIZE)
        .map(|i| ((i * 29 + 13) % 256) as u8)   // fill with prime series of consistant but reproducable values
        .collect()                              // wow i sure hope this doesn't overflow or anything
}

fn run_crc(data: &[u8]) -> u32 {
    crc32c(data)    // crc32b is not available natively with Rust, using crc32c as 
}                   // somewhat comparable alternative (this is just for fun anyway)

fn main() {
    let data = make_buffer();       // create buffer
    let crc = run_crc(&data);       // run crc function
    println!("CRC = {:08X}", crc);  // print result
}

