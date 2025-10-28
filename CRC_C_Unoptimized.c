// using raw CRC algorithm
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#define BUFFER_SIZE (10 * 1024 * 1024)

uint8_t *create_buffer(void) {
    uint8_t *buf = malloc(BUFFER_SIZE);         // generate 10MB of buffer
    for (size_t i = 0; i < BUFFER_SIZE; i++) {  // fill with prime series of consistant but reproducable values
        buf[i] = (uint8_t)(i * 29 + 13);
    }
    return buf;
}

uint32_t run_crc(uint8_t *data, size_t len) {
    uint32_t crc = 0xFFFFFFFF;
    for (size_t i = 0; i < len; i++) {
        crc ^= data[i];                         // crc xor with the data to process
        for (uint8_t j = 0; j < 8; j++) {       // loop through each bit
            if (crc & 1) {                      // if crc and bitwise 1 != 0
                crc = (crc >> 1) ^ 0xEDB88320;  // shift 1 bit and xor with polynomial
            }
            else {
                crc = (crc >> 1);               // shift 1 bit
            }
        }
    }
    return ~crc;
}

void main(void) {
    uint8_t *data = create_buffer();            // create buffer
    uint32_t crc = run_crc(data, BUFFER_SIZE);  // run crc function
    printf("CRC = %08X\n", crc);                // print result
}