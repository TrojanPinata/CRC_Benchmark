// using NEON crc32c hardware optimization
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include <arm_acle.h>

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
        crc = __crc32b(crc, data[i]);   // using crc32b since that's what i'm familiar with
    }
    return ~crc;
}

void main(void) {
    uint8_t *data = create_buffer();            // create buffer
    uint32_t crc = run_crc(data, BUFFER_SIZE);  // run crc function
    printf("CRC = %08X\n", crc);                // print result
}