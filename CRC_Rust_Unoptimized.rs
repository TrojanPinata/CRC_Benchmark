// Rust no crc package optimization
const BUFFER_SIZE: usize = 10 * 1024 * 1024;

fn make_buffer() -> Vec<u8> {   // generate 10MB of buffer
    (0..BUFFER_SIZE)
        .map(|i| ((i * 29 + 13) % 256) as u8)   // fill with prime series of consistant but reproducable values
        .collect()                              // wow i sure hope this doesn't overflow or anything
}

fn run_crc(data: &[u8]) -> u32 {
    let mut crc: u32 = 0xFFFFFFFF;
    for &byte in data {
        crc ^= byte as u32;                     // crc xor with the data to process
        for _ in 0..8 {                         // loop through each bit
            if crc & 1 != 0 {                   // if crc and bitwise 1 != 0
                crc = (crc >> 1) ^ 0xEDB88320;  // shift 1 bit and xor with polynomial
            } 
            else {
                crc = (crc >> 1);               // shift 1 bit
            }
        }
    }
    !crc
}

fn main() {
    let data = make_buffer();       // create buffer
    let crc = run_crc(&data);       // run crc function
    println!("CRC = {:08X}", crc);  // print result
}

