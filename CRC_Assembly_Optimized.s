.section .rodata
fmt:
    .string "CRC = %08X\n"

BUFFER_SIZE = 10485760              // 10MB: 10 * 1024 * 1024

.section .bss
    .align 3
buffer_size :
    .skip BUFFER_SIZE               // reserve buffer

.section .text
.global main
.extern malloc
.extern printf


// create_buffer()
create_buffer:
    stp     x29, x30, [sp, -16]!
    mov     x0, #BUFFER_SIZE       // x0 = buffer_size
    bl      malloc                 // malloc 10MB
    mov     x1, x0                 // put buffer pointer in x1
    mov     x2, #0                 // loop counter

create_loop:
    cmp     x2, #BUFFER_SIZE
    b.ge    create_done

    // (i * 29 + 13)
    mov     x3, x2
    mov     x4, #29
    mul     x3, x3, x4
    add     x3, x3, #13
    and     w3, w3, #0xFF           // add mask
    strb    w3, [x1, x2]            // store byte in array
    add     x2, x2, #1
    b       create_loop

create_done:
    mov     x0, x1                 // return buffer pointer
    ldp     x29, x30, [sp], 16
    ret


// run_crc()
run_crc:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp
    mov     w2, #0xFFFFFFFF         // default crc value
    mov     x3, #0                  // count = 0

crc_loop:
    cmp     x3, x1                  // check count is less than length
    b.ge    crc_done
    ldrb    w4, [x0, x3]            // get data from array
    crc32b  w2, w2, w4              // crc = __crc32b(crc, data[i])

    add     x3, x3, #1
    b       crc_loop

crc_done:
    mvn     w0, w2                  // invert crc result
    ldp     x29, x30, [sp], 16
    ret


// main()
main:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    bl      create_buffer           // create buffer pointer
    mov     x1, #BUFFER_SIZE        // add length arg to x1
    bl      run_crc                 // run_crc
    mov     w1, w0                  // crc result
    ldr     x0, =fmt                // print
    bl      printf

    ldp     x29, x30, [sp], 16
    mov     w0, #0
    ret
