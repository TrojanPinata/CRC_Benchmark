// ARMv8 assembly with no NEON optimization, only algorithm
.global main
.extern printf  // same function as in C, better comparison
.extern exit

.section .data
format:
    .asciz "CRC32 result = 0x%08X\n"    // match what's written in C

.section .text

create_buffer:


crc_byte_loop:
    ldrb    w3, [x0], #1    // load byte and increment pointer
    eor     w2, w2, w3      // crc ^= data[i]
    mov     w4, #8          // inner bit loop counter

crc_bit_loop:



run_crc:



main:
    // generate buffer
    // run crc  (place in w0)


    ldr     x0, =format      // format string
    bl      printf

    mov     w0, 0           // exit(0)
    bl      exit